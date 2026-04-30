#!/usr/bin/env sh
# generated: generated/init/term/kitty init
# shellcheck shell=sh

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${TERMINAL_PREFIX:=$XDG_OPT_HOME/1-terminal}"

ready_marker="$HOME/.local/state/_404/bootstrap/10-terminal.ready"
[ -f "$ready_marker" ] || return 0 2>/dev/null || exit 0

if [ -r "${TERMINAL_PREFIX}/env.sh" ]; then
  . "${TERMINAL_PREFIX}/env.sh"
fi
if [ -r "${TERMINAL_PREFIX}/functions.sh" ]; then
  . "${TERMINAL_PREFIX}/functions.sh"
fi

if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH"; export PATH ;;
  esac
fi
