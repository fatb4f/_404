#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"

: "${CODEX_ROOT:?CODEX_ROOT is required}"
: "${CODEX_DRY_RUN:=0}"

if ! command -v zsh >/dev/null 2>&1; then
  if ! codex_install_pkg zsh; then
    printf >&2 'zsh not found and could not be installed\n'
    exit 127
  fi
fi

source_dir="$ROOT/noninteractive-shell/files"
target_dir="$CODEX_ROOT/00-shell"

install_file() {
  src=$1
  dst=$2
  mode=$3

  printf 'activate %-22s %s -> %s\n' "00-shell" "${src#$ROOT/}" "$dst"
  [ "$CODEX_DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  atomic_copy_file "$src" "$dst" "$mode"
}

install_file "$source_dir/init.sh" "$target_dir/init.sh" 0644
install_file "$source_dir/env.sh" "$target_dir/env.sh" 0644
install_file "$source_dir/path.sh" "$target_dir/path.sh" 0644
install_file "$source_dir/require.sh" "$target_dir/require.sh" 0644

codex_stage_mark_ready "00-shell"
