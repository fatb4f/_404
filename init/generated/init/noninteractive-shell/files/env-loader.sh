#!/usr/bin/env sh
# generated shell env loader: 0-noninteractive-shell
# shellcheck shell=sh

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_DATA_HOME:=$DOTS_HOME/.local/share}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${TOOL_PREFIX_HOME:=${TOOL_PATH_HOME%/bin}}"
[ "$TOOL_PREFIX_HOME" != "$TOOL_PATH_HOME" ] || TOOL_PREFIX_HOME=$(dirname "$TOOL_PATH_HOME")

export DOTS_REPO DOTS_DIR DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME

: "${bootstrap_ready:=$XDG_STATE_HOME/_404/bootstrap/00-shell.ready}"
[ -f "$bootstrap_ready" ] || return 0 2>/dev/null || exit 0

if [ -r "$XDG_OPT_HOME/0-noninteractive-shell/env.sh" ]; then
  . "$XDG_OPT_HOME/0-noninteractive-shell/env.sh"
fi
if [ -r "$XDG_OPT_HOME/0-interactive-shell/env.sh" ]; then
  . "$XDG_OPT_HOME/0-interactive-shell/env.sh"
fi
if [ -r "$XDG_OPT_HOME/1-terminal/env.sh" ]; then
  . "$XDG_OPT_HOME/1-terminal/env.sh"
fi
if [ -r "$XDG_OPT_HOME/2-agent/env.sh" ]; then
  . "$XDG_OPT_HOME/2-agent/env.sh"
fi
if [ -r "$XDG_OPT_HOME/go/env.sh" ]; then
  . "$XDG_OPT_HOME/go/env.sh"
fi
if [ -r "$XDG_OPT_HOME/0-noninteractive-shell/path.sh" ]; then
  . "$XDG_OPT_HOME/0-noninteractive-shell/path.sh"
fi
