#!/usr/bin/env bash
# stage deterministic PATH baseline
# Stage 0 shell scope. This is sourced from $STAGE_ROOT/00-shell/init.sh.

_path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

_path_prepend "$TOOL_PATH_HOME"
export PATH
