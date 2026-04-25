#!/usr/bin/env bash
set -euo pipefail

# Print one supported host class:
#   arch-base
#   debian-base
#
# Penguin/Borealis-like Debian environments intentionally collapse to
# debian-base. ChromeOS-specific packages are profile overlays, not a third
# base class.

if [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  id_like=" ${ID_LIKE:-} "
  id="${ID:-}"

  case "$id" in
    arch|artix|endeavouros|manjaro)
      printf 'arch-base\n'
      exit 0
      ;;
    debian|ubuntu|linuxmint|pop)
      printf 'debian-base\n'
      exit 0
      ;;
  esac

  case "$id_like" in
    *' arch '*)
      printf 'arch-base\n'
      exit 0
      ;;
    *' debian '*|*' ubuntu '*)
      printf 'debian-base\n'
      exit 0
      ;;
  esac
fi

if command -v pacman >/dev/null 2>&1; then
  printf 'arch-base\n'
  exit 0
fi

if command -v apt-get >/dev/null 2>&1; then
  printf 'debian-base\n'
  exit 0
fi

printf 'unsupported\n'
exit 1
