#!/usr/bin/env sh
# codex terminal stage init env

: "${CODEX_ROOT:?CODEX_ROOT is required}"
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_STATE_HOME:=${HOME}/.local/state}"
: "${XDG_CACHE_HOME:=${HOME}/.cache}"

export KITTY_CONFIG_DIRECTORY="${KITTY_CONFIG_DIRECTORY:-$CODEX_ROOT/10-terminal/kitty}"
export KITTY_CACHE_DIRECTORY="${KITTY_CACHE_DIRECTORY:-$XDG_CACHE_HOME/kitty}"
export CODEX_TERMINAL_STATE="${CODEX_TERMINAL_STATE:-$XDG_STATE_HOME/codex/terminal}"
export CODEX_BOOTSTRAP_STATE="${CODEX_BOOTSTRAP_STATE:-$XDG_STATE_HOME/codex/bootstrap}"
