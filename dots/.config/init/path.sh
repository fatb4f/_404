#!/usr/bin/env sh
# canonical shell init PATH policy.
# shellcheck shell=sh

init_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}"; export PATH ;;
  esac
}

: "${TOOL_PATH_HOME:=$HOME/.local/bin}"

if [ -d "$TOOL_PATH_HOME" ]; then
  init_path_prepend "$TOOL_PATH_HOME"
fi
