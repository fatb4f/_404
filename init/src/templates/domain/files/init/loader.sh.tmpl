#!/usr/bin/env sh
# canonical shell init loader.
# shellcheck shell=sh

case ${_404_INIT_LOADER_LOADED:-0} in
  1) return 0 2>/dev/null || exit 0 ;;
esac
_404_INIT_LOADER_LOADED=1

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

export _404_INIT_LOADER_LOADED DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME INIT_ROOT INIT_LOADER

if [ -r "$INIT_ROOT/check.sh" ]; then
  . "$INIT_ROOT/check.sh"
fi
if type init_validate_root >/dev/null 2>&1; then
  init_validate_root "$INIT_ROOT" || return 0 2>/dev/null || exit 0
fi

if [ -r "$INIT_ROOT/env.sh" ]; then
  . "$INIT_ROOT/env.sh"
fi
if [ -r "$INIT_ROOT/path.sh" ]; then
  . "$INIT_ROOT/path.sh"
fi
