# -*- mode: sh; mode: sh-bash -*-
# ble.sh modular init entrypoint.
# This file is intended to be used as:
#   source -- "$HOME/.local/share/blesh/ble.sh" --attach=none --rcfile "$HOME/.config/blesh/init.sh"

# shellcheck shell=bash

ble_blerc_dir=${BLE_BLERC_DIR:-${BASH_SOURCE[0]%/*}/blerc.d}

for ble_blerc_file in "$ble_blerc_dir"/*.bash; do
  [[ -e $ble_blerc_file ]] || continue
  source -- "$ble_blerc_file"
done

unset -v ble_blerc_dir ble_blerc_file
