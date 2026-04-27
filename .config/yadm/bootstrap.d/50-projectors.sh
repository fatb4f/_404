# shellcheck shell=bash

bootstrap_project_dotctl() {
  local root
  local generated
  local dst
  local state_home
  local substrate_dir
  local substrate_snapshot
  local cmd

  bootstrap_require_env \
    XDG_CONFIG_HOME \
    XDG_STATE_HOME \
    TOOL_PATH_HOME

  root="$XDG_CONFIG_HOME/dotctl"
  generated="$root/dotctl"
  dst="$TOOL_PATH_HOME/dotctl"
  state_home="${XDG_STATE_HOME:-$HOME/.local/state}"
  substrate_dir="$state_home/dotctl"
  substrate_snapshot="$substrate_dir/substrate.json"

  for cmd in cue bashly jq; do
    command -v "$cmd" >/dev/null 2>&1 || {
      printf 'missing required command: %s\n' "$cmd" >&2
      return 1
    }
  done

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf 'DRY_RUN observe substrate -> %s\n' "$substrate_snapshot"
    printf 'DRY_RUN cue vet substrate -> %s\n' "$root/policy/substrate.cue"
    printf 'DRY_RUN generate/project dotctl -> %s\n' "$dst"
    return 0
  fi

  mkdir -p "$substrate_dir"
  "$root/observe-substrate.sh" > "$substrate_snapshot"
  cue vet "$root/policy/substrate.cue" "$substrate_snapshot" -d '#Substrate'

  (
    cd "$root" || return
    bashly generate
    chmod 0755 "$generated"
  )

  if [[ ! -x "$generated" ]]; then
    printf 'missing generated dotctl: %s\n' "$generated" >&2
    return 1
  fi

  mkdir -p "$TOOL_PATH_HOME"
  install -m 0755 "$generated" "$dst"
  rm -f "$generated"
}

bootstrap_project_dotctl
