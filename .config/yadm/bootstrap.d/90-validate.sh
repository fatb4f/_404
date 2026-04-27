#!/usr/bin/env bash

bootstrap_validate_final_state() {
  bootstrap_require_env TOOL_PATH_HOME

  if [[ ! -x "$TOOL_PATH_HOME/dotctl" ]]; then
    printf 'missing projected dotctl: %s\n' "$TOOL_PATH_HOME/dotctl" >&2
    return 1
  fi

  "$TOOL_PATH_HOME/dotctl" audit
}

bootstrap_validate_final_state
