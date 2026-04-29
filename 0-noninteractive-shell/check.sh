#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"
. "$ROOT/policy/lib/report.sh"

if command -v bash >/dev/null 2>&1; then
  :
else
  emit_check noninteractive-shell bash-available false fatal "bash not found on PATH"
  exit 1
fi

CODEX_ROOT="${CODEX_ROOT:-$(codex_current_root)}"

if codex_stage_require_ready "00-shell"; then
  emit_check noninteractive-shell stage-ready true ok "00-shell handoff marker present"
else
  emit_check noninteractive-shell stage-ready false degraded "00-shell handoff marker missing"
  exit 1
fi

if [ -f "$CODEX_ROOT/00-shell/init.sh" ] && \
   [ -f "$CODEX_ROOT/00-shell/env.sh" ] && \
   [ -f "$CODEX_ROOT/00-shell/path.sh" ] && \
   [ -f "$CODEX_ROOT/00-shell/require.sh" ] && \
   bash -n \
     "$CODEX_ROOT/00-shell/init.sh" \
     "$CODEX_ROOT/00-shell/env.sh" \
     "$CODEX_ROOT/00-shell/path.sh" \
     "$CODEX_ROOT/00-shell/require.sh"; then
  emit_check noninteractive-shell bash-parse true ok "stage 0 files parse"
else
  emit_check noninteractive-shell bash-parse false fatal "stage 0 file missing or parse failure"
  exit 1
fi

if [ -f "$CODEX_ROOT/00-shell/init.sh" ] && grep -q 'codex_source_required' "$CODEX_ROOT/00-shell/init.sh"; then
  emit_check noninteractive-shell load-order true ok "stage 0 require API present"
else
  emit_check noninteractive-shell load-order false degraded "stage 0 require API missing"
  exit 1
fi
