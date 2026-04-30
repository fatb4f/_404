#!/usr/bin/env sh
# generated: 0-noninteractive-shell init
# shellcheck shell=sh

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$XDG_DATA_HOME/_404/dots}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${TOOL_PREFIX_HOME:=${TOOL_PATH_HOME%/bin}}"
[ "$TOOL_PREFIX_HOME" != "$TOOL_PATH_HOME" ] || TOOL_PREFIX_HOME=$(dirname "$TOOL_PATH_HOME")
: "${NONINTERACTIVE_SHELL_PREFIX:=$XDG_OPT_HOME/0-noninteractive-shell}"

# Source the domain env before the ready-marker check. This is intentionally
# limited to env only: it lets customized XDG_STATE_HOME/TOOL_PATH_HOME move
# with the generated seed while still preventing full domain init before ready.
if [ -r "$NONINTERACTIVE_SHELL_PREFIX/env.sh" ]; then
  . "$NONINTERACTIVE_SHELL_PREFIX/env.sh"
fi

ready_marker="$XDG_STATE_HOME/_404/bootstrap/00-shell.ready"
[ -f "$ready_marker" ] || return 0 2>/dev/null || exit 0

if [ -r "${NONINTERACTIVE_SHELL_PREFIX}/require.sh" ]; then
  . "${NONINTERACTIVE_SHELL_PREFIX}/require.sh"
fi
if [ -r "${NONINTERACTIVE_SHELL_PREFIX}/env.sh" ]; then
  . "${NONINTERACTIVE_SHELL_PREFIX}/env.sh"
fi
if [ -r "${NONINTERACTIVE_SHELL_PREFIX}/path.sh" ]; then
  . "${NONINTERACTIVE_SHELL_PREFIX}/path.sh"
fi

if [ -d "$TOOL_PATH_HOME" ]; then
  case ":$PATH:" in
    *":$TOOL_PATH_HOME:"*) ;;
    *) PATH="$TOOL_PATH_HOME:$PATH"; export PATH ;;
  esac
fi
