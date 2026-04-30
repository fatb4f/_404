#!/usr/bin/env sh
# canonical shell init env.
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
case $TOOL_PATH_HOME in
  */bin) ;;
  *) TOOL_PATH_HOME=$HOME/.local/bin; TOOL_PREFIX_HOME=${TOOL_PATH_HOME%/bin} ;;
esac
: "${INIT_ROOT:=$DOTS_HOME/.config/init}"
: "${INIT_LOADER:=$INIT_ROOT/loader.sh}"
: "${BASH_ENV:=$DOTS_HOME/.bash_env}"

export DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME INIT_ROOT INIT_LOADER BASH_ENV
