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

CODEX_ROOT="${CODEX_ROOT:-$(codex_current_root)}"

if codex_stage_require_ready "00-shell" && codex_stage_require_ready "interactive-shell"; then
  emit_check interactive-shell stage-ready true ok "shell handoff markers present"
else
  emit_check interactive-shell stage-ready false degraded "shell handoff marker missing"
  exit 1
fi

if [ -f "$HOME/.zshenv" ] && zsh -n "$HOME/.zshenv" && \
   grep -q 'bootstrap/00-shell.ready' "$HOME/.zshenv" && \
   grep -q 'CODEX_ROOT/00-shell/init.sh' "$HOME/.zshenv"; then
  emit_check interactive-shell zshenv-parse true ok ".zshenv parses and loads stage 0"
else
  emit_check interactive-shell zshenv-parse false fatal ".zshenv missing, parse failure, or stage 0 load missing"
  exit 1
fi

if [ -f "$HOME/.zshrc" ] && zsh -n "$HOME/.zshrc" && \
   ! grep -q 'CODEX_ROOT/10-terminal/init.sh' "$HOME/.zshrc" && \
   ! grep -q 'CODEX_ROOT/20-agent/init.sh' "$HOME/.zshrc"; then
  emit_check interactive-shell zshrc-parse true ok ".zshrc parses and stays local"
else
  emit_check interactive-shell zshrc-parse false degraded ".zshrc missing, parse failure, or downstream references present"
  exit 1
fi

if [ -d "$CODEX_ROOT" ]; then
  emit_check interactive-shell codex-root-present true ok "CODEX_ROOT present"
else
  emit_check interactive-shell codex-root-present false degraded "CODEX_ROOT missing"
  exit 1
fi
