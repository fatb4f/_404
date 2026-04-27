# shellcheck shell=bash

bootstrap_project_dotctl() {
  local src
  local dst

  bootstrap_require_env \
    XDG_CONFIG_HOME \
    TOOL_PATH_HOME

  src="$XDG_CONFIG_HOME/dotctl/bin/dotctl"
  dst="$TOOL_PATH_HOME/dotctl"

  if [[ ! -x "$src" ]]; then
    printf 'missing executable dotctl source: %s\n' "$src" >&2
    return 1
  fi

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf 'DRY_RUN project dotctl %s -> %s\n' "$dst" "$src"
    return 0
  fi

  mkdir -p "$TOOL_PATH_HOME"
  ln -sfn "$src" "$dst"
}

bootstrap_project_dotctl
