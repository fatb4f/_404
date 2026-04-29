#!/usr/bin/env sh
# stage terminal stage init env

: "${STAGE_ROOT:?STAGE_ROOT is required}"
: "${XDG_CONFIG_HOME:=${HOME}/.config}"
: "${XDG_STATE_HOME:=${HOME}/.local/state}"
: "${XDG_CACHE_HOME:=${HOME}/.cache}"

export KITTY_CONFIG_DIRECTORY="${KITTY_CONFIG_DIRECTORY:-$STAGE_ROOT/10-terminal/kitty}"
export KITTY_CACHE_DIRECTORY="${KITTY_CACHE_DIRECTORY:-$XDG_CACHE_HOME/kitty}"
export TERMINAL_STATE="${TERMINAL_STATE:-$XDG_STATE_HOME/_404/terminal}"
export BOOTSTRAP_STATE="${BOOTSTRAP_STATE:-$XDG_STATE_HOME/_404/bootstrap}"
