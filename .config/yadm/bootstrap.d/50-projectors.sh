# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/bashly.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/cue.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/fs.sh"

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

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf 'DRY_RUN observe substrate -> %s\n' "$substrate_snapshot"
    printf 'DRY_RUN cue vet substrate -> %s\n' "$root/policy/substrate.cue"
    printf 'DRY_RUN generate/project dotctl -> %s\n' "$dst"
    return 0
  fi

  dotctl_fs_mkdir_p "$substrate_dir"
  "$root/observe-substrate.sh" > "$substrate_snapshot"
  dotctl_cue_vet "$root/policy/substrate.cue" "$substrate_snapshot" '#Substrate'

  dotctl_bashly_generate "$root"
  chmod 0755 "$generated"

  if [[ ! -x "$generated" ]]; then
    printf 'missing generated dotctl: %s\n' "$generated" >&2
    return 1
  fi

  dotctl_fs_mkdir_p "$TOOL_PATH_HOME"
  dotctl_fs_install -m 0755 "$generated" "$dst"
  dotctl_fs_rm_rf "$generated"
}

bootstrap_project_dotctl
