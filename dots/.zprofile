#!/usr/bin/env sh
# login shell bootstrap for zsh.
# shellcheck shell=sh

: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${DOTS_HOME:=$XDG_DATA_HOME/_404/dots}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${INIT_ROOT:=$DOTS_HOME/.config/init}"
: "${INIT_LOADER:=$INIT_ROOT/loader.sh}"

[ -r "$INIT_LOADER" ] && . "$INIT_LOADER"
