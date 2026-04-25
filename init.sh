#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${_404_REPO_URL:-https://github.com/fatb4f/_404.git}"
REPO_ROOT="${_404_REPO_ROOT:-${HOME}/.local/opt/_404}"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

have() {
  command -v "$1" >/dev/null 2>&1
}

install_git() {
  if have git; then
    return 0
  fi

  if have apt-get; then
    have sudo || die 'sudo is required to install git'
    sudo -n env DEBIAN_FRONTEND=noninteractive apt-get update
    sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y git
    return 0
  fi

  if have pacman; then
    have sudo || die 'sudo is required to install git'
    sudo -n pacman -Syu --needed --noconfirm git
    return 0
  fi

  die 'no package manager available to install git'
}

checkout_repo() {
  local repo_parent
  repo_parent="$(dirname -- "$REPO_ROOT")"
  mkdir -p -- "$repo_parent"

  if [[ -d "$REPO_ROOT/.git" ]]; then
    git -C "$REPO_ROOT" fetch --all --prune
    git -C "$REPO_ROOT" pull --ff-only
    return 0
  fi

  if [[ -e "$REPO_ROOT" ]] && [[ -n "$(find "$REPO_ROOT" -mindepth 1 -maxdepth 1 2>/dev/null | head -n 1 || true)" ]]; then
    die "refusing to reuse non-git directory: $REPO_ROOT"
  fi

  rm -rf -- "$REPO_ROOT"
  git clone "$REPO_URL" "$REPO_ROOT"
}

main() {
  install_git
  checkout_repo
  exec bash "$REPO_ROOT/strap/bootstrap" "$@"
}

main "$@"
