#!/usr/bin/env bash
set -euo pipefail

install_arch_packages() {
  local manifest_dir=${1:?manifest_dir}
  local packages=()
  local file pkg

  for file in "$manifest_dir/arch-base.pkgs"; do
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
    printf '[dry-run] sudo -n pacman -Sy\n'
  else
    sudo -n pacman -Sy
  fi

  local resolved=()
  for pkg in "${packages[@]}"; do
    if ! pacman -Si "$pkg" >/dev/null 2>&1; then
      die "arch-base package does not resolve: $pkg"
    fi
    resolved+=("$pkg")
  done

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n pacman -Syu --needed --noconfirm'
    printf ' %q' "${resolved[@]}"
    printf '\n'
    return 0
  fi

  if ! command -v pacman >/dev/null 2>&1; then
    die 'pacman not found for arch-base'
  fi

  sudo -n pacman -Syu --needed --noconfirm "${resolved[@]}"
}
