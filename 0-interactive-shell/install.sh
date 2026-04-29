#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"

: "${DRY_RUN:=0}"

if ! command -v zsh >/dev/null 2>&1; then
  printf >&2 'zsh not found on PATH\n'
  exit 127
fi

install_file() {
  src=$1
  dst=$2
  mode=$3

  printf 'activate %-22s %s -> %s\n' "interactive-shell" "${src#$ROOT/}" "$dst"
  [ "$DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  atomic_copy_file "$src" "$dst" "$mode"
}

install_file "$ROOT/0-interactive-shell/files/zshenv" "$HOME/.zshenv" 0644
install_file "$ROOT/0-interactive-shell/files/zshrc" "$HOME/.zshrc" 0644
