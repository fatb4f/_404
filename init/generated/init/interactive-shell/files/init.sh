#!/usr/bin/env sh
# generated: generated/init/interactive-shell init
# shellcheck shell=sh

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${INTERACTIVE_SHELL_PREFIX:=$XDG_OPT_HOME/0-interactive-shell}"

ready_marker="$HOME/.local/state/_404/bootstrap/interactive-shell.ready"
[ -f "$ready_marker" ] || return 0 2>/dev/null || exit 0

if [ -r "${INTERACTIVE_SHELL_PREFIX}/env.sh" ]; then
  . "${INTERACTIVE_SHELL_PREFIX}/env.sh"
fi

if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH"; export PATH ;;
  esac
fi
