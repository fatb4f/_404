#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"

: "${CODEX_AGENT_PREFIX:=${CODEX_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/codex/current}}"
: "${CODEX_DRY_RUN:=0}"

codex_stage_require_ready "10-terminal"

source_dir="$ROOT/2-agent/files"
target_dir="$CODEX_AGENT_PREFIX/20-agent"

install_file() {
  src=$1
  dst=$2
  mode=$3

  printf 'activate %-22s %s -> %s\n' "20-agent" "${src#$ROOT/}" "$dst"
  [ "$CODEX_DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  atomic_copy_file "$src" "$dst" "$mode"
}

install_file "$source_dir/init.sh" "$target_dir/init.sh" 0644
install_file "$source_dir/env.sh" "$target_dir/env.sh" 0644
install_file "$source_dir/functions.sh" "$target_dir/functions.sh" 0644
install_file "$source_dir/bin/shell_tool" "$target_dir/bin/shell_tool" 0755
install_file "$source_dir/bin/shell_snapshot" "$target_dir/bin/shell_snapshot" 0755

install_link() {
  src=$1
  dst=$2

  printf 'activate %-22s %s -> %s\n' "20-agent" "$src" "$dst"
  [ "$CODEX_DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

install_link "$CODEX_AGENT_PREFIX/20-agent/bin/shell_tool" "$HOME/.local/bin/shell_tool"
install_link "$CODEX_AGENT_PREFIX/20-agent/bin/shell_snapshot" "$HOME/.local/bin/shell_snapshot"

codex_stage_mark_ready "20-agent"
