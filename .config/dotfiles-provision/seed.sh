#!/usr/bin/env bash
set -euo pipefail

repo="${DOTFILES_REPO:-https://github.com/fatb4f/_404.git}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'missing required command: %s\n' "$1" >&2
    return 1
  }
}

need git
need yadm

if ! yadm status >/dev/null 2>&1; then
  yadm clone "$repo"
fi

yadm bootstrap

if [[ -r "$HOME/.config/shell/load-env.sh" ]]; then
  # shellcheck source=/dev/null
  . "$HOME/.config/shell/load-env.sh"
fi

if command -v just >/dev/null 2>&1; then
  just check
else
  printf 'warning: just not found after bootstrap\n' >&2
  exit 1
fi
