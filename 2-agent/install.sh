#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"

: "${CODEX_AGENT_PREFIX:=${CODEX_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/_404/current}}"
: "${CODEX_DRY_RUN:=0}"

stage_require_ready "10-terminal"

if ! command -v npm >/dev/null 2>&1; then
  if ! install_pkg npm; then
    printf >&2 'npm not found and could not be installed\n'
    exit 127
  fi
fi

if ! command -v codex >/dev/null 2>&1; then
  if [ "${CODEX_DRY_RUN}" -eq 1 ]; then
    printf 'would install codex via npm\n'
  else
    npm install -g --prefix "$HOME/.local" @openai/codex
  fi
fi

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

stage_mark_ready "20-agent"
