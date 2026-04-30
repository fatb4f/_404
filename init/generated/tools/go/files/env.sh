#!/usr/bin/env sh
# generated: go env
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

: "${GO_PREFIX:=$XDG_OPT_HOME/go}"
: "${GO_STATE:=$XDG_STATE_HOME/_404/go}"
: "${GO_CACHE:=$XDG_CACHE_HOME/_404/go}"
: "${GO_BIN_HOME:=$XDG_OPT_HOME/go/bin}"
: "${GO_SHARE_HOME:=$XDG_OPT_HOME/go/share}"

export GO_PREFIX GO_STATE GO_CACHE GO_BIN_HOME GO_SHARE_HOME

: "${GOPATH:=$HOME/go}"
: "${GOBIN:=$GOPATH/bin}"
if command -v _path_prepend >/dev/null 2>&1; then
  _path_prepend "$GOBIN"
else
  case ":$PATH:" in
    *":$GOBIN:"*) ;;
    *) PATH="$GOBIN${PATH:+:$PATH}"; export PATH ;;
  esac
fi
export GOPATH GOBIN PATH
