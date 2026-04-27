# shellcheck shell=bash

dotctl_bashly_generate() {
  local repo="${1:?missing dotctl repo}"

  command -v bashly >/dev/null 2>&1 || {
    printf 'missing required command: bashly\n' >&2
    return 1
  }

  (
    cd "$repo" || return
    bashly generate
  )
}
