#!/usr/bin/env bash

bootstrap_require_env \
  XDG_CACHE_HOME \
  XDG_CONFIG_HOME \
  XDG_DATA_HOME \
  XDG_STATE_HOME \
  TOOL_PATH_HOME \
  XDG_DATA_BIN \
  DIR_BOOTSTRAP

bootstrap_mkdirs \
  "$XDG_CACHE_HOME" \
  "$XDG_CONFIG_HOME" \
  "$XDG_DATA_HOME" \
  "$XDG_STATE_HOME" \
  "$TOOL_PATH_HOME" \
  "$XDG_DATA_BIN" \
  "$DIR_BOOTSTRAP"
