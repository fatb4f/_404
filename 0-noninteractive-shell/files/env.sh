#!/usr/bin/env bash
# codex noninteractive env baseline
# Stage 0 shell scope. This is sourced from $CODEX_ROOT/00-shell/init.sh.

: "${HOME:?HOME is required}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export CODEX_BOOTSTRAP_STATE="${CODEX_BOOTSTRAP_STATE:-$XDG_STATE_HOME/codex/bootstrap}"
export CODEX_ROOT="${CODEX_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/codex/current}"
