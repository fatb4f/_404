#!/usr/bin/env bash

if [[ -n "${YADM_BOOTSTRAP_COMMON_LOADED:-}" ]]; then
  return 0
fi
YADM_BOOTSTRAP_COMMON_LOADED=1

BOOTSTRAP_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
BOOTSTRAP_PKG_DIR="$BOOTSTRAP_DIR/pkgs"

log() { printf '[%s] %s\n' "${1:?level}" "${*:2}" >&2; }
info() { log info "$@"; }
warn() { log warn "$@"; }
die() { log error "$@"; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }

run() {
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

require_cmd() {
  local missing=0 cmd
  for cmd in "$@"; do
    if ! have "$cmd"; then
      warn "missing command: $cmd"
      missing=1
    fi
  done
  return "$missing"
}

ensure_dir() {
  local dir=${1:?dir}
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] mkdir -p %q\n' "$dir"
  else
    mkdir -p -- "$dir"
  fi
}

copy_file() {
  local src=${1:?src} dst=${2:?dst} mode=${3:-0644}
  ensure_dir "$(dirname -- "$dst")"
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] install -m %q %q %q\n' "$mode" "$src" "$dst"
  else
    install -m "$mode" -- "$src" "$dst"
  fi
}

xdg_config_home() {
  local home_dir=${1:-$HOME}
  local config_home=${XDG_CONFIG_HOME:-$home_dir/.config}
  printf '%s\n' "${config_home%/}"
}
