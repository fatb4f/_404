# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/env.sh"

dotctl_git_require_tools() {
  local cmd

  for cmd in "$@"; do
    command -v "$cmd" >/dev/null 2>&1 || {
      printf 'missing required command: %s\n' "$cmd" >&2
      return 1
    }
  done
}

dotctl_git_json_array() {
  local -a items=("$@")

  if ((${#items[@]} == 0)); then
    printf '[]'
    return 0
  fi

  printf '%s\0' "${items[@]}" | jq -Rs 'split("\u0000")[:-1]'
}

dotctl_git_normalize_status_path() {
  local path="$1"

  case "$path" in
    *" -> "*) printf '%s\n' "${path##* -> }" ;;
    *) printf '%s\n' "$path" ;;
  esac
}

dotctl_git_collect_status() {
  local line status path

  while IFS= read -r line; do
    [[ "$line" == "##"* ]] && continue
    [[ -z "$line" ]] && continue

    status="${line:0:2}"
    path="$(dotctl_git_normalize_status_path "${line:3}")"

    case "$status" in
      "??")
        printf 'untracked\t%s\n' "$path"
        ;;
      "!!")
        printf 'ignored\t%s\n' "$path"
        ;;
      *)
        if [[ "$status" == *D* ]]; then
          printf 'deleted\t%s\n' "$path"
        else
          printf 'dirty\t%s\n' "$path"
        fi
        ;;
    esac
  done < <(git -C "$HOME" status --porcelain=v1 --branch --untracked-files=all --ignored)

  while IFS= read -r -d '' path; do
    [[ -n "$path" ]] && printf 'tracked\t%s\n' "$path"
  done < <(git -C "$HOME" ls-files -z --full-name)
}

dotctl_git_observe() {
  local output_json=""
  local repo worktree branch upstream head ahead behind
  local -a tracked=() dirty=() untracked=() deleted=() ignored=()
  local generated_dotctl generated_bin_dotctl
  local tmpdir tracked_json dirty_json untracked_json deleted_json ignored_json
  local arg

  if [[ "${1:-}" == *.json ]]; then
    output_json="$1"
    shift
  fi

  for arg in "$@"; do
    [[ -n "$arg" ]] && : # reserved for future target selectors
  done

  dotctl_git_require_tools git jq

  repo="$(git -C "$HOME" rev-parse --git-dir)"
  worktree="$(git -C "$HOME" rev-parse --show-toplevel)"
  branch="$(git -C "$HOME" symbolic-ref -q --short HEAD || printf 'HEAD')"
  upstream="$(git -C "$HOME" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || true)"
  head="$(git -C "$HOME" rev-parse HEAD)"
  ahead=0
  behind=0

  if [[ -n "$upstream" ]]; then
    read -r ahead behind < <(
      git -C "$HOME" rev-list --left-right --count "HEAD...@{u}"
    )
  fi

  while IFS=$'\t' read -r category path; do
    [[ -n "$path" ]] || continue

    case "$category" in
      tracked) tracked+=("$path") ;;
      dirty) dirty+=("$path") ;;
      untracked) untracked+=("$path") ;;
      deleted) deleted+=("$path") ;;
      ignored) ignored+=("$path") ;;
    esac
  done < <(dotctl_git_collect_status)

  generated_dotctl=false
  generated_bin_dotctl=false
  if git -C "$HOME" ls-files --error-unmatch ".config/dotctl/dotctl" >/dev/null 2>&1; then
    generated_dotctl=true
  fi
  if git -C "$HOME" ls-files --error-unmatch ".config/dotctl/bin/dotctl" >/dev/null 2>&1; then
    generated_bin_dotctl=true
  fi

  tmpdir="$(mktemp -d)"
  tracked_json="$tmpdir/tracked.json"
  dirty_json="$tmpdir/dirty.json"
  untracked_json="$tmpdir/untracked.json"
  deleted_json="$tmpdir/deleted.json"
  ignored_json="$tmpdir/ignored.json"

  dotctl_git_json_array "${tracked[@]}" > "$tracked_json"
  dotctl_git_json_array "${dirty[@]}" > "$dirty_json"
  dotctl_git_json_array "${untracked[@]}" > "$untracked_json"
  dotctl_git_json_array "${deleted[@]}" > "$deleted_json"
  dotctl_git_json_array "${ignored[@]}" > "$ignored_json"

  jq -n \
    --arg repo "$repo" \
    --arg worktree "$worktree" \
    --arg branch "$branch" \
    --arg upstream "${upstream:-}" \
    --arg head "$head" \
    --argjson ahead "$ahead" \
    --argjson behind "$behind" \
    --rawfile tracked_json "$tracked_json" \
    --rawfile dirty_json "$dirty_json" \
    --rawfile untracked_json "$untracked_json" \
    --rawfile deleted_json "$deleted_json" \
    --rawfile ignored_json "$ignored_json" \
    --argjson generated_dotctl "$generated_dotctl" \
    --argjson generated_bin_dotctl "$generated_bin_dotctl" \
    '{
      schema: "dotctl.git.substrate.observed.v0",
      backend: {
        kind: "git",
        isWorktree: true,
        repo: $repo,
        worktree: $worktree
      },
      refs: {
        branch: $branch,
        upstream: (if $upstream == "" then null else $upstream end),
        head: $head,
        ahead: $ahead,
        behind: $behind
      },
      paths: {
        tracked: ($tracked_json | fromjson),
        dirty: ($dirty_json | fromjson),
        untracked: ($untracked_json | fromjson),
        deleted: ($deleted_json | fromjson),
        ignored: ($ignored_json | fromjson)
      },
      generated: {
        ".config/dotctl/dotctl": $generated_dotctl,
        ".config/dotctl/bin/dotctl": $generated_bin_dotctl
      },
      syntax_failures: {}
    }' > "${output_json:-/dev/stdout}"

  rm -rf "$tmpdir"
}

dotctl_git_vet() {
  local input_json="${1:?missing git substrate snapshot}"

  dotctl_git_require_tools cue
  cue vet "$DOTCTL_GIT_POLICY" "$input_json" -d '#GitSubstrate'
}

dotctl_git_project_state() {
  local input_json="${1:?missing git substrate snapshot}"

  dotctl_git_require_tools jq

  if [[ "${DOTCTL_GIT_ASSUME_VETTED:-0}" != 1 ]]; then
    dotctl_git_vet "$input_json"
  fi

  mkdir -p \
    "$DOTCTL_GIT_CACHE_HOME" \
    "$DOTCTL_GIT_STATE_HOME" \
    "$DOTCTL_GIT_DATA_HOME"

  if [[ "$input_json" != "$DOTCTL_GIT_OBSERVE_JSON" ]]; then
    cp "$input_json" "$DOTCTL_GIT_OBSERVE_JSON"
  fi
  cp "$input_json" "$DOTCTL_GIT_LAST_VETTED_JSON"

  jq '{schema:"dotctl.git.current.v0", backend:.backend, refs:.refs, paths:.paths, generated:.generated}' \
    "$input_json" > "$DOTCTL_GIT_CURRENT_JSON"

  jq '{schema:"dotctl.git.dirty.v0", dirty:.paths.dirty, untracked:.paths.untracked, deleted:.paths.deleted, ignored:.paths.ignored}' \
    "$input_json" > "$DOTCTL_GIT_DIRTY_JSON"

  jq '{schema:"dotctl.git.tracked.v0", tracked:.paths.tracked}' \
    "$input_json" > "$DOTCTL_GIT_TRACKED_JSON"

  jq '{schema:"dotctl.git.refs.v0", refs:.refs}' \
    "$input_json" > "$DOTCTL_GIT_REFS_JSON"
}

dotctl_git_refresh() {
  local observe_json="$DOTCTL_GIT_OBSERVE_JSON"

  mkdir -p "$DOTCTL_GIT_CACHE_HOME"
  dotctl_git_observe "$observe_json" >/dev/null
  dotctl_git_vet "$observe_json"
  DOTCTL_GIT_ASSUME_VETTED=1 dotctl_git_project_state "$observe_json" >/dev/null
  dotctl_git_status
}

dotctl_git_status() {
  local snapshot="$DOTCTL_GIT_CURRENT_JSON"
  local cleanup_snapshot=false

  if [[ ! -f "$snapshot" ]]; then
    snapshot="$(mktemp)"
    cleanup_snapshot=true
    dotctl_git_observe "$snapshot" >/dev/null
  fi

  jq -r '
    [
      ["backend.kind", .backend.kind],
      ["backend.repo", .backend.repo],
      ["backend.worktree", .backend.worktree],
      ["refs.branch", .refs.branch],
      ["refs.upstream", (.refs.upstream // "null")],
      ["refs.head", .refs.head],
      ["refs.ahead", .refs.ahead],
      ["refs.behind", .refs.behind],
      ["paths.tracked", (.paths.tracked | length)],
      ["paths.dirty", (.paths.dirty | length)],
      ["paths.untracked", (.paths.untracked | length)],
      ["paths.deleted", (.paths.deleted | length)],
      ["paths.ignored", (.paths.ignored | length)]
    ]
    | .[]
    | "\(.[0])\t\(.[1])"
  ' "$snapshot"

  if [[ "$cleanup_snapshot" == true ]]; then
    rm -f "$snapshot"
  fi
}
