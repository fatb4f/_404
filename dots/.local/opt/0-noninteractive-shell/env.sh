#!/usr/bin/env sh
# generated: 0-noninteractive-shell env
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
case $TOOL_PATH_HOME in
  */bin) ;;
  *) TOOL_PATH_HOME=$HOME/.local/bin; TOOL_PREFIX_HOME=${TOOL_PATH_HOME%/bin} ;;
esac

: "${NONINTERACTIVE_SHELL_PREFIX:=$XDG_OPT_HOME/0-noninteractive-shell}"
: "${NONINTERACTIVE_SHELL_STATE:=$XDG_STATE_HOME/_404/0-noninteractive-shell}"
: "${NONINTERACTIVE_SHELL_CACHE:=$XDG_CACHE_HOME/_404/0-noninteractive-shell}"
: "${NONINTERACTIVE_SHELL_BIN_HOME:=$XDG_OPT_HOME/0-noninteractive-shell/bin}"
: "${NONINTERACTIVE_SHELL_SHARE_HOME:=$XDG_OPT_HOME/0-noninteractive-shell/share}"

: "${BOOTSTRAP_STATE:=$XDG_STATE_HOME/_404/bootstrap}"
export BOOTSTRAP_STATE
: "${STAGE_ROOT:=$NONINTERACTIVE_SHELL_PREFIX}"
export STAGE_ROOT
