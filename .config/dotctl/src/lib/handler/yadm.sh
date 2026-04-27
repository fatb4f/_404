# shellcheck shell=bash

dotctl_yadm_handler() {
  command -v yadm >/dev/null 2>&1 || {
    printf 'missing required command: yadm\n' >&2
    return 1
  }

  yadm "$@"
}
