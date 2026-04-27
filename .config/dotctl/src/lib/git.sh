# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/env.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/cue.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/fs.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/git.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/jq.sh"

dotctl_git_json_array() {
  local -a items=("$@")

  if ((${#items[@]} == 0)); then
    printf '[]'
    return 0
  fi

  printf '%s\0' "${items[@]}" | dotctl_jq -Rs 'split("\u0000")[:-1]'
}

dotctl_git_collect_addable_paths() {
  local input_json="${1:?missing git substrate snapshot}"

  dotctl_jq -r '
    [
      .paths.dirty[],
      .paths.untracked[],
      .paths.deleted[]
    ]
    | unique[]
  ' "$input_json"
}

dotctl_git_load_pathset() {
  local input_json="${1:?missing git substrate snapshot}"
  local -n pathset_ref="${2:?missing pathset reference}"
  local path

  while IFS= read -r path; do
    [[ -n "$path" ]] && pathset_ref["$path"]=1
  done < <(dotctl_git_collect_addable_paths "$input_json")
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
  done < <(dotctl_git_status_porcelain "$HOME")

  while IFS= read -r -d '' path; do
    [[ -n "$path" ]] && printf 'tracked\t%s\n' "$path"
  done < <(dotctl_git_ls_files_z "$HOME")
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

  repo="$(dotctl_git_rev_parse_git_dir "$HOME")"
  worktree="$(dotctl_git_rev_parse_toplevel "$HOME")"
  branch="$(dotctl_git_symbolic_branch "$HOME" || printf 'HEAD')"
  upstream="$(dotctl_git_upstream_ref "$HOME")"
  head="$(dotctl_git_head_rev "$HOME")"
  ahead=0
  behind=0

  if [[ -n "$upstream" ]]; then
    read -r ahead behind < <(
      dotctl_git_ahead_behind "$HOME"
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
  if dotctl_git_ls_files_error_unmatch "$HOME" ".config/dotctl/dotctl"; then
    generated_dotctl=true
  fi
  if dotctl_git_ls_files_error_unmatch "$HOME" ".config/dotctl/bin/dotctl"; then
    generated_bin_dotctl=true
  fi

  tmpdir="$(dotctl_fs_mktemp_dir)"
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

  dotctl_jq -n \
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

  dotctl_fs_rm_rf "$tmpdir"
}

dotctl_git_vet() {
  local input_json="${1:?missing git substrate snapshot}"

  dotctl_cue_vet "$DOTCTL_GIT_POLICY" "$input_json" '#GitSubstrate'
}

dotctl_git_project_state() {
  local input_json="${1:?missing git substrate snapshot}"

  if [[ "${DOTCTL_GIT_ASSUME_VETTED:-0}" != 1 ]]; then
    dotctl_git_vet "$input_json"
  fi

  dotctl_fs_mkdir_p \
    "$DOTCTL_GIT_CACHE_HOME" \
    "$DOTCTL_GIT_STATE_HOME" \
    "$DOTCTL_GIT_DATA_HOME"

  if [[ "$input_json" != "$DOTCTL_GIT_OBSERVE_JSON" ]]; then
    dotctl_fs_cp "$input_json" "$DOTCTL_GIT_OBSERVE_JSON"
  fi
  dotctl_fs_cp "$input_json" "$DOTCTL_GIT_LAST_VETTED_JSON"

  dotctl_jq '{schema:"dotctl.git.current.v0", backend:.backend, refs:.refs, paths:.paths, generated:.generated}' \
    "$input_json" > "$DOTCTL_GIT_CURRENT_JSON"

  dotctl_jq '{schema:"dotctl.git.dirty.v0", dirty:.paths.dirty, untracked:.paths.untracked, deleted:.paths.deleted, ignored:.paths.ignored}' \
    "$input_json" > "$DOTCTL_GIT_DIRTY_JSON"

  dotctl_jq '{schema:"dotctl.git.tracked.v0", tracked:.paths.tracked}' \
    "$input_json" > "$DOTCTL_GIT_TRACKED_JSON"

  dotctl_jq '{schema:"dotctl.git.refs.v0", refs:.refs}' \
    "$input_json" > "$DOTCTL_GIT_REFS_JSON"
}

dotctl_git_refresh() {
  local observe_json="$DOTCTL_GIT_OBSERVE_JSON"

  dotctl_fs_mkdir_p "$DOTCTL_GIT_CACHE_HOME"
  dotctl_git_observe "$observe_json" >/dev/null
  dotctl_git_vet "$observe_json"
  DOTCTL_GIT_ASSUME_VETTED=1 dotctl_git_project_state "$observe_json" >/dev/null
  dotctl_git_status
}

dotctl_git_add() {
  local tmpdir snapshot plan_json requested_json resolved_json
  local -a requested_targets=() resolved_targets=() observed_targets=()
  local -A addable=()
  local target

  for target in "$@"; do
    [[ -n "$target" ]] && requested_targets+=("$target")
  done

  tmpdir="$(dotctl_fs_mktemp_dir)"
  snapshot="$tmpdir/observe.json"
  plan_json="$tmpdir/add-plan.json"

  dotctl_git_observe "$snapshot" >/dev/null
  dotctl_git_vet "$snapshot"
  dotctl_git_load_pathset "$snapshot" addable

  if ((${#requested_targets[@]} == 0)); then
    printf 'dotctl git add requires at least one PATH\n' >&2
    rm -rf "$tmpdir"
    return 1
  fi

  for target in "${requested_targets[@]}"; do
    if [[ -z "${addable[$target]:-}" ]]; then
      printf 'refusing to stage non-addable path: %s\n' "$target" >&2
      rm -rf "$tmpdir"
      return 1
    fi
    resolved_targets+=("$target")
  done

  for target in "${resolved_targets[@]}"; do
    case "$target" in
      ".config/dotctl/dotctl"|".config/dotctl/bin/dotctl")
        printf 'refusing to stage generated dotctl artifact: %s\n' "$target" >&2
        rm -rf "$tmpdir"
        return 1
        ;;
    esac
  done

  requested_json="$(dotctl_git_json_array "${requested_targets[@]}")"
  resolved_json="$(dotctl_git_json_array "${resolved_targets[@]}")"

  dotctl_jq -n \
    --slurpfile observed "$snapshot" \
    --argjson requested_targets "$requested_json" \
    --argjson resolved_targets "$resolved_json" \
    '{
      schema: "dotctl.git.add.plan.v0",
      operation: "add",
      observed: $observed[0],
      requested_targets: $requested_targets,
      resolved_targets: $resolved_targets
    }' > "$plan_json"

  dotctl_cue_vet "$DOTCTL_GIT_POLICY" "$plan_json" '#GitAddPlan'

  dotctl_git_add_paths "$HOME" "${resolved_targets[@]}"
  dotctl_git_refresh
  dotctl_fs_rm_rf "$tmpdir"
}

dotctl_git_status() {
  local snapshot="$DOTCTL_GIT_CURRENT_JSON"
  local snapshot_dir=""
  local cleanup_snapshot=false

  if [[ ! -f "$snapshot" ]]; then
    snapshot_dir="$(dotctl_fs_mktemp_dir)"
    snapshot="$snapshot_dir/status.json"
    cleanup_snapshot=true
    dotctl_git_observe "$snapshot" >/dev/null
  fi

  dotctl_jq -r '
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
    dotctl_fs_rm_rf "$snapshot"
    [[ -n "$snapshot_dir" ]] && dotctl_fs_rm_rf "$snapshot_dir"
  fi
}
