# shellcheck shell=bash

: "${HOME:?HOME is required}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"

DOTCTL_CONFIG_HOME="${DOTCTL_CONFIG_HOME:-$XDG_CONFIG_HOME/dotctl}"
DOTCTL_AUDIT_HOME="${DOTCTL_AUDIT_HOME:-$XDG_CONFIG_HOME/dotfiles-audit}"
DOTCTL_AUDIT_STATE_HOME="${DOTCTL_AUDIT_STATE_HOME:-$XDG_STATE_HOME/dotfiles-audit}"

DOTCTL_AUDIT_TARGETS_DEFAULT=(
  ".config/bin"
  ".config/broot"
  ".config/nvim"
  ".config/uv"
)
