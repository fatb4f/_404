# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/audit.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/bashly.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/fs.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/git.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/yadm.sh"

dotctl_check_shell() {
  "$XDG_CONFIG_HOME/shell/validate-env.sh"
}

dotctl_check_bootstrap() {
  bash -n "$XDG_CONFIG_HOME/yadm/bootstrap"

  for f in "$XDG_CONFIG_HOME"/yadm/bootstrap.d/*.sh; do
    bash -n "$f"
  done

  DRY_RUN=1 HOST_CLASS="${HOST_CLASS:-debian-base}" dotctl_yadm_bootstrap
}

dotctl_check_all() {
  dotctl_check_shell
  dotctl_check_bootstrap
  dotctl_git_refresh
  dotctl_audit_run
  dotctl_yadm_status
}
