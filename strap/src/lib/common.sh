#!/usr/bin/env bash

if [[ -n "${_404_COMMON_SH_LOADED:-}" ]]; then
  return 0
fi
_404_COMMON_SH_LOADED=1

log() { printf '[%s] %s\n' "${1:?level}" "${*:2}" >&2; }
info() { log info "$@"; }
warn() { log warn "$@"; }
die() { log error "$@"; exit 1; }

run() {
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

have() { command -v "$1" >/dev/null 2>&1; }

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

repo_root() {
  local here=${STRAP_ROOT:?STRAP_ROOT is not set}
  CDPATH= cd -- "$here/../.." && pwd -P
}
