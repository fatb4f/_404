# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/env.sh"

dotctl_audit_observe() {
  local output_json=""
  local -a targets=()
  local audit_home="${DOTCTL_AUDIT_HOME}"
  local state_home="${DOTCTL_AUDIT_STATE_HOME}"
  local ts audit_dir records
  local arg

  if [[ "${1:-}" == *.json ]]; then
    output_json="$1"
    shift
  fi

  for arg in "$@"; do
    [[ -n "$arg" ]] && targets+=("$arg")
  done

  if ((${#targets[@]} == 0)); then
    targets=("${DOTCTL_AUDIT_TARGETS_DEFAULT[@]}")
  fi

  ts="$(date +%Y%m%d-%H%M%S)"
  audit_dir="$state_home/$ts"
  records="$audit_dir/inventory.ndjson"

  mkdir -p "$audit_dir"
  : > "$records"

  dotctl_audit_collect_records "${targets[@]}" > "$records"
  dotctl_audit_render_json "$records" "$audit_dir/audit.json"

  if [[ -n "$output_json" && "$output_json" != "$audit_dir/audit.json" ]]; then
    cp "$audit_dir/audit.json" "$output_json"
  else
    cat "$audit_dir/audit.json"
  fi
}

dotctl_audit_collect_records() {
  local target abs path

  for target in "$@"; do
    abs="$HOME/$target"
    [[ -e "$abs" ]] || continue

    find "$abs" -mindepth 1 \( -type f -o -type l \) 2>/dev/null |
      sort |
      while IFS= read -r path; do
        dotctl_audit_observe_path "$path"
      done
  done
}

dotctl_audit_observe_path() {
  local path="$1"
  local rel family kind tracked identity_hit syntax_checked syntax_ok syntax_tool

  rel="${path#"$HOME"/}"
  family="$(dotctl_audit_family_for_path "$rel")"
  kind="$(dotctl_audit_kind_for_path "$path")"
  tracked=false
  identity_hit=false
  syntax_checked=false
  syntax_ok=null
  syntax_tool=null

  if yadm ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
    tracked=true
  fi

  if dotctl_audit_is_identity_hit "$path"; then
    identity_hit=true
  fi

  IFS=$'\t' read -r syntax_checked syntax_ok syntax_tool < <(dotctl_audit_syntax_probe "$path" "$kind")

  jq -n \
    --arg path "$rel" \
    --arg family "$family" \
    --arg kind "$kind" \
    --argjson tracked "$tracked" \
    --argjson identity_hit "$identity_hit" \
    --argjson syntax_checked "$syntax_checked" \
    --argjson syntax_ok "$syntax_ok" \
    --arg syntax_tool "$syntax_tool" \
    '{
      path: $path,
      family: $family,
      kind: $kind,
      tracked: $tracked,
      identity_hit: $identity_hit,
      syntax: {
        checked: $syntax_checked,
        ok: $syntax_ok,
        tool: (if $syntax_tool == "null" then null else $syntax_tool end)
      }
    }'
}

dotctl_audit_family_for_path() {
  case "$1" in
    .config/bin|.config/bin/*) printf 'bin\n' ;;
    .config/broot|.config/broot/*) printf 'broot\n' ;;
    .config/nvim|.config/nvim/*) printf 'nvim\n' ;;
    .config/uv|.config/uv/*) printf 'uv\n' ;;
    *) printf 'unknown\n' ;;
  esac
}

dotctl_audit_kind_for_path() {
  local path="$1"

  if [[ -L "$path" ]]; then
    printf 'symlink\n'
  elif [[ -f "$path" ]]; then
    printf 'file\n'
  else
    printf 'other\n'
  fi
}

dotctl_audit_is_identity_hit() {
  local path="$1"

  [[ -f "$path" ]] || return 1
  grep -Iq . "$path" 2>/dev/null || return 1

  grep -Eq '/home/[^[:space:]"'"'"']+|/home/_404|_404|x404' "$path" 2>/dev/null
}

dotctl_audit_syntax_probe() {
  local path="$1"
  local kind="$2"
  local first_line ext

  if [[ "$kind" != "file" ]]; then
    printf '%s\t%s\t%s\n' false null null
    return 0
  fi

  if ! grep -Iq . "$path" 2>/dev/null; then
    printf '%s\t%s\t%s\n' false null null
    return 0
  fi

  first_line="$(head -n 1 "$path" 2>/dev/null || true)"
  ext="${path##*.}"

  case "$first_line" in
    *bash*|*sh*|*zsh*)
      if bash -n "$path" >/dev/null 2>&1; then
        printf '%s\t%s\t%s\n' true true 'bash -n'
      else
        printf '%s\t%s\t%s\n' true false 'bash -n'
      fi
      ;;
    *)
      case "$ext" in
        lua)
          if command -v luac >/dev/null 2>&1; then
            if luac -p "$path" >/dev/null 2>&1; then
              printf '%s\t%s\t%s\n' true true 'luac -p'
            else
              printf '%s\t%s\t%s\n' true false 'luac -p'
            fi
          else
            printf '%s\t%s\t%s\n' false null null
          fi
          ;;
        *)
          printf '%s\t%s\t%s\n' false null null
          ;;
      esac
      ;;
  esac
}

dotctl_audit_render_json() {
  local records="$1"
  local audit_json="$2"

  jq -s '
    def obs: {path, kind, family};
    def mapify(stream):
      reduce stream[] as $r ({}; .[$r.path] = $r);

    {
      schema: "dotfiles.audit.v1",
      mode: "allowlist",
      observed: {
        live_files: mapify([.[] | obs]),
        yadm_tracked: mapify([.[] | select(.tracked == true) | obs]),
        identity_hits: mapify([.[] | select(.identity_hit == true) | {path, kind, family}]),
        syntax_failures: mapify([.[] | select(.syntax.checked == true and .syntax.ok == false) | {path, kind, family, syntax}])
      }
    }
  ' "$records" > "$audit_json"
}

dotctl_audit_summary() {
  local audit_json="$1"

  jq -r '
    [
      ["live_files", (.observed.live_files | length)],
      ["yadm_tracked", (.observed.yadm_tracked | length)],
      ["identity_hits", (.observed.identity_hits | length)],
      ["syntax_failures", (.observed.syntax_failures | length)]
    ]
    | .[]
    | "\(.[0])\t\(.[1])"
  ' "$audit_json"
}

dotctl_audit_vet() {
  local audit_json="$1"

  cue vet "$HOME/.config/dotfiles-audit/policy/dotfiles_audit.cue" "$audit_json" -d '#Audit'
}

dotctl_audit_run() {
  local -a targets=()
  local ts audit_dir audit_json
  local arg

  for arg in "$@"; do
    [[ -n "$arg" ]] && targets+=("$arg")
  done

  if ((${#targets[@]} == 0)); then
    targets=("${DOTCTL_AUDIT_TARGETS_DEFAULT[@]}")
  fi

  ts="$(date +%Y%m%d-%H%M%S)"
  audit_dir="${DOTCTL_AUDIT_STATE_HOME}/${ts}"
  audit_json="$audit_dir/audit.json"

  mkdir -p "$audit_dir"
  dotctl_audit_observe "$audit_json" "${targets[@]}" >/dev/null
  dotctl_audit_vet "$audit_json"
  dotctl_audit_summary "$audit_json"
  printf 'audit=%s\n' "$audit_dir"
}
