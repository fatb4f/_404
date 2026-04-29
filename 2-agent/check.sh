#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"
. "$ROOT/policy/lib/report.sh"

CODEX_ROOT="${CODEX_ROOT:-$(current_root)}"
CODEX_AGENT_PREFIX="${CODEX_AGENT_PREFIX:-${CODEX_ROOT}}"

if stage_require_ready "10-terminal" && stage_require_ready "20-agent"; then
  emit_check agent stage-ready true ok "terminal and agent handoff markers present"
else
  emit_check agent stage-ready false degraded "agent handoff marker missing"
  exit 1
fi

status=0

for path in \
  "$CODEX_AGENT_PREFIX/20-agent/init.sh" \
  "$CODEX_AGENT_PREFIX/20-agent/env.sh" \
  "$CODEX_AGENT_PREFIX/20-agent/functions.sh" \
  "$CODEX_AGENT_PREFIX/20-agent/bin/shell_tool" \
  "$CODEX_AGENT_PREFIX/20-agent/bin/shell_snapshot"
do
  if [ -e "$path" ]; then
    emit_check agent "$(basename "$path")-present" true ok "$path present"
  else
    emit_check agent "$(basename "$path")-present" false degraded "$path missing"
    status=1
  fi
done

[ "$status" -eq 0 ] || exit "$status"

if command -v npm >/dev/null 2>&1; then
  emit_check agent npm-available true ok "npm found on PATH"
else
  emit_check agent npm-available false fatal "npm not found on PATH"
  exit 1
fi

if command -v codex >/dev/null 2>&1; then
  emit_check agent codex-available true ok "codex found on PATH"
else
  emit_check agent codex-available false fatal "codex not found on PATH"
  exit 1
fi

if sh -n \
  "$CODEX_AGENT_PREFIX/20-agent/init.sh" \
  "$CODEX_AGENT_PREFIX/20-agent/env.sh" \
  "$CODEX_AGENT_PREFIX/20-agent/functions.sh"; then
  emit_check agent agent-load-order true ok "agent stage files parse"
else
  emit_check agent agent-load-order false fatal "agent stage parse failure"
  exit 1
fi

snapshot="$("$CODEX_AGENT_PREFIX/20-agent/bin/shell_snapshot" 2>/dev/null)" || {
  emit_check agent shell_snapshot false degraded "shell snapshot failed"
  exit 1
}

if command -v python3 >/dev/null 2>&1 && printf '%s\n' "$snapshot" | python3 -c 'import json, sys; data=json.load(sys.stdin); assert "agent_prefix" in data and "agent_state" in data'; then
  emit_check agent shell_snapshot true ok "shell snapshot available"
else
  emit_check agent shell_snapshot false degraded "shell snapshot output invalid"
  exit 1
fi
