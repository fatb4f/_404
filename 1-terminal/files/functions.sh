#!/usr/bin/env sh
# stage terminal wrapper functions

kitty_launch_with_cwd() {
  cwd="${1:-$PWD}"
  shift || true

  command -v kitty >/dev/null 2>&1 || {
    printf >&2 'kitty not found on PATH\n'
    return 127
  }

  kitty --config "${KITTY_CONFIG_DIRECTORY:?}/kitty.conf" --directory "$cwd" "$@"
}

kitty_t0() {
  kitty_launch_with_cwd "$PWD" "$@"
}
