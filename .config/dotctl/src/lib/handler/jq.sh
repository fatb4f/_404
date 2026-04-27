# shellcheck shell=bash

dotctl_jq() {
  command -v jq >/dev/null 2>&1 || {
    printf 'missing required command: jq\n' >&2
    return 1
  }

  jq "$@"
}
