#!/usr/bin/env bash
set -euo pipefail

repo="${DOTFILES_REPO:-https://github.com/fatb4f/_404.git}"
bootstrap_root="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-bootstrap"
clone_dir="$bootstrap_root/src"
work_dir="$bootstrap_root/work"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    printf 'missing required command: %s\n' "$1" >&2
    return 1
  }
}

ensure_clone() {
  if [[ -d "$clone_dir/.git" ]]; then
    return 0
  fi

  mkdir -p "$bootstrap_root"
  git clone "$repo" "$clone_dir"
}

need git
need bash
ensure_clone

export DOTFILES_BOOTSTRAP_MODE=git
export DOTFILES_BOOTSTRAP_ROOT="$bootstrap_root"
export DOTFILES_BOOTSTRAP_REPO="$clone_dir"
export DIR_BOOTSTRAP="$work_dir"
export XDG_CONFIG_HOME="$clone_dir/.config"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export TOOL_PATH_HOME="${TOOL_PATH_HOME:-$XDG_DATA_HOME/path}"
export XDG_DATA_BIN="${XDG_DATA_BIN:-$HOME/.local/bin}"
export HOME="${HOME:?HOME is required}"
export HOST_CLASS="${HOST_CLASS:-debian-base}"

seed_script="${DOTFILES_BOOTSTRAP_SEED:-$clone_dir/.config/dotfiles-provision/bootstrap-git-seed.sh}"

bash "$seed_script"

if [[ -r "$clone_dir/.config/shell/load-env.sh" ]]; then
  # shellcheck source=/dev/null
  . "$clone_dir/.config/shell/load-env.sh"
fi

if command -v dotctl >/dev/null 2>&1; then
  dotctl doctor --json >/dev/null
  dotctl audit run >/dev/null
  dotctl check
elif command -v just >/dev/null 2>&1; then
  just check
else
  printf 'warning: no controller found after bootstrap\n' >&2
  exit 1
fi
