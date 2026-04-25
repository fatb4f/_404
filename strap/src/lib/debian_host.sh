#!/usr/bin/env bash
set -euo pipefail

install_debian_packages() {
  local manifest_dir=${1:?manifest_dir}
  local packages=()
  local file pkg

  for file in "$manifest_dir/debian-base.pkgs"; do
    [[ -r "$file" ]] || continue
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
      pkg=${pkg%%#*}
      pkg=${pkg//[$'\t\r\n ']}
      [[ -n "$pkg" ]] || continue
      packages+=("$pkg")
    done < "$file"
  done

  ((${#packages[@]})) || return 0

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n apt-get update\n'
  else
    sudo -n apt-get update
  fi

  local resolved=()
  for pkg in "${packages[@]}"; do
    if ! apt-cache show "$pkg" >/dev/null 2>&1; then
      die "debian-base package does not resolve: $pkg"
    fi
    resolved+=("$pkg")
  done

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y'
    printf ' %q' "${resolved[@]}"
    printf '\n'
    return 0
  fi

  if ! command -v apt-get >/dev/null 2>&1; then
    die 'apt-get not found for debian-base'
  fi

  sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y "${resolved[@]}"
}
