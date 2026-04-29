#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"
. "$ROOT/policy/lib/report.sh"

if command -v zsh >/dev/null 2>&1; then
  :
else
  emit_check interactive-shell zsh-available false fatal "zsh not found on PATH"
  exit 1
fi

if [ -f "$HOME/.zshenv" ] && zsh -n "$HOME/.zshenv"; then
  emit_check interactive-shell zshenv-parse true ok ".zshenv parses"
else
  emit_check interactive-shell zshenv-parse false fatal ".zshenv missing or parse failure"
  exit 1
fi

if [ -f "$HOME/.zshrc" ] && zsh -n "$HOME/.zshrc"; then
  emit_check interactive-shell zshrc-parse true ok ".zshrc parses"
else
  emit_check interactive-shell zshrc-parse false fatal ".zshrc missing or parse failure"
  exit 1
fi
