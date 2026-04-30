#!/usr/bin/env sh
# generated: generated/init/noninteractive-shell init
# shellcheck shell=sh

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${NONINTERACTIVE_SHELL_PREFIX:=$XDG_OPT_HOME/0-noninteractive-shell}"

ready_marker="$HOME/.local/state/_404/bootstrap/00-shell.ready"
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

if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH"; export PATH ;;
  esac
fi
