# shellcheck shell=bash

bootstrap_project_dotctl() {
  local root
  local generated
  local dst

  bootstrap_require_env \
    XDG_CONFIG_HOME \
    TOOL_PATH_HOME

  root="$XDG_CONFIG_HOME/dotctl"
  generated="$root/dotctl"
  dst="$TOOL_PATH_HOME/dotctl"

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf 'DRY_RUN generate/project dotctl -> %s\n' "$dst"
    return 0
  fi

  (
    cd "$root" || return
    bashly generate
    chmod 0755 "$generated"
  )

  if [[ ! -x "$generated" ]]; then
    printf 'missing generated dotctl: %s\n' "$generated" >&2
    return 1
  fi

  mkdir -p "$TOOL_PATH_HOME"
  install -m 0755 "$generated" "$dst"
  rm -f "$generated"
}

bootstrap_project_dotctl
