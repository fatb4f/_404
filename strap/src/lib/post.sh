#!/usr/bin/env bash
set -euo pipefail

post_dotfiles() {
  local _project_root=${1:?project_root}
  local yazi_dir="$HOME/.config/yazi"
  local package_toml="$yazi_dir/package.toml"

  if [[ ! -r "$package_toml" ]]; then
    warn "yazi package manifest missing; skipping post step: $package_toml"
    return 0
  fi

  if [[ "${DRY_RUN:-0}" != 1 ]]; then
    require_cmd ya || die 'ya is required for the yazi post step'
  elif ! command -v ya >/dev/null 2>&1; then
    warn 'ya not found; dry-run continues'
  fi

  info "installing yazi packages from $package_toml"
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] cd %q && ya pkg install\n' "$yazi_dir"
    return 0
  fi

  (
    cd -- "$yazi_dir"
    ya pkg install
  )
}
