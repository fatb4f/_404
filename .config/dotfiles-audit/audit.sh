#!/usr/bin/env bash
set -euo pipefail

: "${HOME:?HOME is required}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"

targets=("$@")
if ((${#targets[@]} == 0)); then
  targets=(
    ".config/bin"
    ".config/broot"
    ".config/nvim"
    ".config/uv"
  )
fi

ts="$(date +%Y%m%d-%H%M%S)"
audit="$XDG_STATE_HOME/dotfiles-audit/$ts"
records="$audit/inventory.ndjson"

mkdir -p "$audit"
: > "$records"

family_for_path() {
  case "$1" in
    .config/bin|.config/bin/*) printf 'bin\n' ;;
    .config/broot|.config/broot/*) printf 'broot\n' ;;
    .config/nvim|.config/nvim/*) printf 'nvim\n' ;;
    .config/uv|.config/uv/*) printf 'uv\n' ;;
    *) printf 'unknown\n' ;;
  esac
}

kind_for_path() {
  local path="$1"

  if [[ -L "$path" ]]; then
    printf 'symlink\n'
  elif [[ -f "$path" ]]; then
    printf 'file\n'
  else
    printf 'other\n'
  fi
}

is_identity_hit() {
  local path="$1"

  [[ -f "$path" ]] || return 1
  grep -Iq . "$path" 2>/dev/null || return 1

  grep -Eq '/home/[^[:space:]"'"'"']+|/home/_404|_404|x404' "$path" 2>/dev/null
}

syntax_probe() {
  local path="$1"
  local kind="$2"
  local first_line ext

  if [[ "$kind" != "file" ]]; then
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

for target in "${targets[@]}"; do
  abs="$HOME/$target"
  [[ -e "$abs" ]] || continue

  find "$abs" -mindepth 1 \( -type f -o -type l \) 2>/dev/null |
    sort |
    while IFS= read -r path; do
      rel="${path#"$HOME"/}"
      family="$(family_for_path "$rel")"
      kind="$(kind_for_path "$path")"

      if yadm ls-files --error-unmatch "$rel" >/dev/null 2>&1; then
        tracked=true
      else
        tracked=false
      fi

      if is_identity_hit "$path"; then
        identity_hit=true
      else
        identity_hit=false
      fi

      IFS=$'\t' read -r syntax_checked syntax_ok syntax_tool < <(syntax_probe "$path" "$kind")

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
        }' >> "$records"
    done
done

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
' "$records" > "$audit/audit.json"

cue vet "$HOME/.config/dotfiles-audit/policy/dotfiles_audit.cue" "$audit/audit.json" -d '#Audit'

jq -r '
  [
    ["live_files", (.observed.live_files | length)],
    ["yadm_tracked", (.observed.yadm_tracked | length)],
    ["identity_hits", (.observed.identity_hits | length)],
    ["syntax_failures", (.observed.syntax_failures | length)]
  ]
  | .[]
  | "\(.[0])\t\(.[1])"
' "$audit/audit.json"

printf 'audit=%s\n' "$audit"
