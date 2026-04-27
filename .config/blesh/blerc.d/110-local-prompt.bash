# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Local prompt integrations

function ble/prompt/backslash:local/vim-mode {
  local mode

  # During early startup, the vi helper may not exist yet.
  declare -F ble/keymap:vi/script/get-mode >/dev/null || return 0

  ble/keymap:vi/script/get-mode

  case $mode in
  [iR$'\022']*) ble/prompt/print '[I]' ;;
  *n) ble/prompt/print '[N]' ;;
  *x) ble/prompt/print '[V]' ;;
  *s) ble/prompt/print '[S]' ;;
  esac
}

## liquidprompt owns PS1. Keep ble.sh's right prompt empty to avoid duplicate
## git/runtime segments and preserve the local vi-mode marker as a prefix.

bleopt prompt_rps1=
LP_PS1_PREFIX='\q{local/vim-mode} '

if [[ -r "$HOME/.local/bin/liquidprompt" ]]; then
  source -- "$HOME/.local/bin/liquidprompt"
fi
