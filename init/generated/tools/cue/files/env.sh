#!/usr/bin/env sh
# generated: cue env
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

export DOTS_REPO DOTS_DIR DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME

: "${CUE_PREFIX:=$XDG_OPT_HOME/cue}"
: "${CUE_STATE:=$XDG_STATE_HOME/_404/cue}"
: "${CUE_CACHE:=$XDG_CACHE_HOME/_404/cue}"
: "${CUE_BIN_HOME:=$XDG_OPT_HOME/cue/bin}"
: "${CUE_SHARE_HOME:=$XDG_OPT_HOME/cue/share}"

export CUE_PREFIX CUE_STATE CUE_CACHE CUE_BIN_HOME CUE_SHARE_HOME


