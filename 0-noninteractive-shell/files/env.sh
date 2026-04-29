#!/usr/bin/env bash
# stage noninteractive env baseline
# Stage 0 shell scope. This is sourced from $STAGE_ROOT/00-shell/init.sh.

: "${HOME:?HOME is required}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export BOOTSTRAP_STATE="${BOOTSTRAP_STATE:-$XDG_STATE_HOME/_404/bootstrap}"
export STAGE_ROOT="${STAGE_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/_404/current}"
