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

if [[ "${DOTFILES_BOOTSTRAP_MODE:-git}" == yadm ]] && command -v yadm >/dev/null 2>&1 && yadm status >/dev/null 2>&1; then
  yadm bootstrap

  if [[ -r "$HOME/.config/shell/load-env.sh" ]]; then
    # shellcheck source=/dev/null
    . "$HOME/.config/shell/load-env.sh"
  fi

  if command -v dotctl >/dev/null 2>&1; then
    dotctl check
  elif command -v just >/dev/null 2>&1; then
    just check
  else
    printf 'warning: no controller found after bootstrap\n' >&2
    exit 1
  fi
else
  exec "$HOME/.config/dotfiles-provision/bootstrap-git.sh"
fi
