#!/usr/bin/env bash
set -euo pipefail

bootstrap_dir="${XDG_CONFIG_HOME}/yadm/bootstrap.d"

# shellcheck source=/dev/null
source "$bootstrap_dir/00-common.sh"
# shellcheck source=/dev/null
source "$bootstrap_dir/20-dirs.sh"
# shellcheck source=/dev/null
source "$bootstrap_dir/30-system.sh"
# shellcheck source=/dev/null
source "$bootstrap_dir/40-userland.sh"

if [[ -r "${XDG_CONFIG_HOME}/shell/load-env.sh" ]]; then
  # shellcheck source=/dev/null
  . "${XDG_CONFIG_HOME}/shell/load-env.sh"
fi

source "${XDG_CONFIG_HOME}/dotctl/src/lib/handler/bashly.sh"
source "${XDG_CONFIG_HOME}/dotctl/src/lib/handler/cue.sh"
source "${XDG_CONFIG_HOME}/dotctl/src/lib/handler/fs.sh"

bootstrap_project_dotctl_git() {
  local root
  local generated
  local dst

  root="${XDG_CONFIG_HOME}/dotctl"
  generated="$root/dotctl"
  dst="$TOOL_PATH_HOME/dotctl"

  dotctl_fs_mkdir_p "$TOOL_PATH_HOME"
  dotctl_bashly_generate "$root"
  chmod 0755 "$generated"
  dotctl_fs_install -m 0755 "$generated" "$dst"
  dotctl_fs_rm_rf "$generated"
}

bootstrap_project_dotctl_git

# shellcheck source=/dev/null
source "$bootstrap_dir/90-validate.sh"
