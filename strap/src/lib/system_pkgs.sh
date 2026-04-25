#!/usr/bin/env bash
set -euo pipefail

install_system_packages() {
  local host_class=${1:?host_class}
  local manifest_dir=${2:?manifest_dir}

  case "$host_class" in
    arch-base)
      install_arch_packages "$manifest_dir"
      ;;
    debian-base)
      install_debian_packages "$manifest_dir"
      ;;
    *)
      die "unsupported host class for package install: $host_class"
      ;;
  esac
}
