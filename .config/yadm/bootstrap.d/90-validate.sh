#!/usr/bin/env bash

if [[ -x "$XDG_CONFIG_HOME/shell/validate-env.sh" ]]; then
  "$XDG_CONFIG_HOME/shell/validate-env.sh"
fi

if [[ -x "$XDG_CONFIG_HOME/dotfiles-audit/audit.sh" ]]; then
  "$XDG_CONFIG_HOME/dotfiles-audit/audit.sh"
fi
