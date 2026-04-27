# shellcheck shell=bash

dotctl_audit_run() {
  local -a targets=("$@")

  if ((${#targets[@]} == 0)); then
    targets=("${DOTCTL_AUDIT_TARGETS_DEFAULT[@]}")
  fi

  "$DOTCTL_AUDIT_HOME/audit.sh" "${targets[@]}"
}
