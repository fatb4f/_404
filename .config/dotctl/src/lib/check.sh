# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/audit.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/doctor.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/bashly.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/fs.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/git.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/yadm.sh"

dotctl_check_shell() {
  "$XDG_CONFIG_HOME/shell/validate-env.sh"
}

dotctl_check_bootstrap() {
  if [[ "${DOTFILES_BOOTSTRAP_MODE:-}" == git ]]; then
    local fragment

    bash -n "$XDG_CONFIG_HOME/yadm/bootstrap"

    for fragment in "$XDG_CONFIG_HOME"/yadm/bootstrap.d/*.sh; do
      bash -n "$fragment"
    done

    [[ -x "$TOOL_PATH_HOME/dotctl" ]] || {
      printf 'missing projected dotctl: %s\n' "$TOOL_PATH_HOME/dotctl" >&2
      return 1
    }

    return 0
  fi

  bash -n "$XDG_CONFIG_HOME/yadm/bootstrap"

  for f in "$XDG_CONFIG_HOME"/yadm/bootstrap.d/*.sh; do
    bash -n "$f"
  done

  DRY_RUN=1 HOST_CLASS="${HOST_CLASS:-debian-base}" dotctl_yadm_bootstrap
}

dotctl_check_all() {
  dotctl_check_shell
  dotctl_check_bootstrap
  dotctl_audit_run
  dotctl_doctor_run false

  if [[ "${DOTFILES_BOOTSTRAP_MODE:-}" != git ]]; then
    dotctl_git_refresh
    dotctl_yadm_status
  fi
}
