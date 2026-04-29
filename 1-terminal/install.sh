#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"

: "${STAGE_ROOT:?STAGE_ROOT is required}"
: "${DRY_RUN:=0}"

stage_require_ready "00-shell"
stage_require_ready "interactive-shell"

source_dir="$ROOT/1-terminal/files"
target_dir="$STAGE_ROOT/10-terminal"

terminal_ensure_kitty() {
  if command -v kitty >/dev/null 2>&1; then
    return 0
  fi

  if install_pkg kitty; then
    return 0
  fi

  printf >&2 'kitty not found and package manager install failed\n'
  return 127
}

terminal_ensure_kitty

install_file() {
  src=$1
  dst=$2
  mode=$3

  printf 'activate %-22s %s -> %s\n' "10-terminal" "${src#$ROOT/}" "$dst"
  [ "$DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  atomic_copy_file "$src" "$dst" "$mode"
}

install_link() {
  src=$1
  dst=$2

  printf 'activate %-22s %s -> %s\n' "10-terminal" "$src" "$dst"
  [ "$DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

install_file "$source_dir/kitty.conf" "$target_dir/kitty/kitty.conf" 0644
install_file "$source_dir/overrides.kitty.conf" "$target_dir/kitty/overrides.kitty.conf" 0644
install_file "$source_dir/env.sh" "$target_dir/env.sh" 0644
install_file "$source_dir/functions.sh" "$target_dir/functions.sh" 0644
install_file "$source_dir/init.sh" "$target_dir/init.sh" 0644
install_file "$source_dir/bin/kitty-t0" "$target_dir/bin/kitty-t0" 0755
install_file "$source_dir/bin/kitty-launch-with-cwd" "$target_dir/bin/kitty-launch-with-cwd" 0755
install_file "$source_dir/bin/kitty-launch-desktop" "$target_dir/bin/kitty-launch-desktop" 0755
install_file "$source_dir/applications/stage-kitty.desktop" "$target_dir/applications/stage-kitty.desktop" 0644
install_file "$source_dir/applications/stage-kitty-workflow.desktop" "$target_dir/applications/stage-kitty-workflow.desktop" 0644

install_link "$STAGE_ROOT/10-terminal/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
install_link "$STAGE_ROOT/10-terminal/kitty/overrides.kitty.conf" "$HOME/.config/kitty/overrides.kitty.conf"
install_link "$STAGE_ROOT/10-terminal/bin/kitty-t0" "$HOME/.local/bin/kitty-t0"
install_link "$STAGE_ROOT/10-terminal/bin/kitty-launch-with-cwd" "$HOME/.local/bin/kitty-launch-with-cwd"
install_link "$STAGE_ROOT/10-terminal/bin/kitty-launch-desktop" "$HOME/.local/bin/kitty-launch-desktop"
install_link "$STAGE_ROOT/10-terminal/applications/stage-kitty.desktop" "$HOME/.local/share/applications/stage-kitty.desktop"
install_link "$STAGE_ROOT/10-terminal/applications/stage-kitty-workflow.desktop" "$HOME/.local/share/applications/stage-kitty-workflow.desktop"

stage_mark_ready "10-terminal"
