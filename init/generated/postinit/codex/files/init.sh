#!/usr/bin/env sh
# generated: generated/postinit/codex init
# shellcheck shell=sh

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${AGENT_PREFIX:=$XDG_OPT_HOME/2-agent}"

ready_marker="$HOME/.local/state/_404/bootstrap/20-agent.ready"
[ -f "$ready_marker" ] || return 0 2>/dev/null || exit 0

if [ -r "${AGENT_PREFIX}/env.sh" ]; then
  . "${AGENT_PREFIX}/env.sh"
fi
if [ -r "${AGENT_PREFIX}/functions.sh" ]; then
  . "${AGENT_PREFIX}/functions.sh"
fi

if [ -d "$HOME/.local/bin" ]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH"; export PATH ;;
  esac
fi
