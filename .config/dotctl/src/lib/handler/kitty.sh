# shellcheck shell=bash

dotctl_kitty_version() {
  command -v kitty >/dev/null 2>&1 || {
    printf 'missing required command: kitty\n' >&2
    return 1
  }

  kitty --version
}
