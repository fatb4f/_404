# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Local integrations

## Keep ble.sh focused on editing and completion, not prompt theming.

if [[ -r "$HOME/.local/opt/bash-completion/bash_completion" ]]; then
  source -- "$HOME/.local/opt/bash-completion/bash_completion"
fi

## Compatibility shim for completion scripts that still call the legacy
## bash-completion API.

if ! declare -F _get_comp_words_by_ref >/dev/null 2>&1 && declare -F _comp_get_words >/dev/null 2>&1; then
  _get_comp_words_by_ref() {
    _comp_get_words "$@"
  }
fi

## Contrib integrations.

ble-import contrib/integration/bash-completion
ble-import -d contrib/integration/fzf-completion
ble-import -d contrib/integration/fzf-key-bindings
ble-import contrib/integration/fzf-git
ble-import contrib/integration/fzf-menu
