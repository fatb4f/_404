#!/usr/bin/env sh
# generated shell env loader: 0-noninteractive-shell
# shellcheck shell=sh

: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${DOTS_HOME:=$XDG_DATA_HOME/_404/dots}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${TOOL_PREFIX_HOME:=${TOOL_PATH_HOME%/bin}}"
[ "$TOOL_PREFIX_HOME" != "$TOOL_PATH_HOME" ] || TOOL_PREFIX_HOME=$(dirname "$TOOL_PATH_HOME")
: "${INIT_ROOT:=$DOTS_HOME/.config/init}"
: "${INIT_LOADER:=$INIT_ROOT/loader.sh}"

[ -r "$INIT_LOADER" ] && . "$INIT_LOADER"

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
if [ -r "$XDG_OPT_HOME/cue/env.sh" ]; then
  . "$XDG_OPT_HOME/cue/env.sh"
fi
if [ -r "$XDG_OPT_HOME/go/env.sh" ]; then
  . "$XDG_OPT_HOME/go/env.sh"
fi
if [ -r "$XDG_OPT_HOME/0-noninteractive-shell/path.sh" ]; then
  . "$XDG_OPT_HOME/0-noninteractive-shell/path.sh"
fi
