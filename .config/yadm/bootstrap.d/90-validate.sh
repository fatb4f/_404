#!/usr/bin/env bash

bootstrap_validate_final_state() {
  bootstrap_require_env TOOL_PATH_HOME

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf 'DRY_RUN validate projected dotctl %s\n' "$TOOL_PATH_HOME/dotctl"
    return 0
  fi

  if [[ ! -x "$TOOL_PATH_HOME/dotctl" ]]; then
    printf 'missing projected dotctl: %s\n' "$TOOL_PATH_HOME/dotctl" >&2
    return 1
  fi

  "$TOOL_PATH_HOME/dotctl" audit run
}

bootstrap_validate_final_state
