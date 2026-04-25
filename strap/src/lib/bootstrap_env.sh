#!/usr/bin/env bash
set -euo pipefail

bootstrap_env() {
  local source_dir=${1:?source_dir}
  local home_dir=${2:-$HOME}
  local config_home=${XDG_CONFIG_HOME:-$home_dir/.config}
  config_home="${config_home%/}"

  info 'seeding minimal shell environment'
  copy_file "$source_dir/load-env.sh" "$config_home/shell/load-env.sh" 0644

  local f
  for f in "$source_dir/env.d"/*.sh; do
    [[ -r "$f" ]] || continue
    copy_file "$f" "$config_home/shell/env.d/${f##*/}" 0644
  done
}
