#!/usr/bin/env sh
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"
. "$ROOT/policy/lib/report.sh"

CODEX_ROOT="${CODEX_ROOT:-$(codex_current_root)}"

if codex_stage_require_ready "00-shell" && codex_stage_require_ready "interactive-shell" && codex_stage_require_ready "10-terminal"; then
  emit_check terminal stage-ready true ok "shell and terminal handoff markers present"
else
  emit_check terminal stage-ready false degraded "terminal handoff marker missing"
  exit 1
fi

status=0
for path in \
  "$CODEX_ROOT/10-terminal/init.sh" \
  "$CODEX_ROOT/10-terminal/env.sh" \
  "$CODEX_ROOT/10-terminal/functions.sh" \
  "$CODEX_ROOT/10-terminal/kitty/kitty.conf" \
  "$CODEX_ROOT/10-terminal/kitty/overrides.kitty.conf" \
  "$CODEX_ROOT/10-terminal/bin/kitty-t0" \
  "$CODEX_ROOT/10-terminal/bin/kitty-launch-with-cwd" \
  "$CODEX_ROOT/10-terminal/bin/kitty-launch-desktop" \
  "$CODEX_ROOT/10-terminal/applications/codex-kitty.desktop" \
  "$CODEX_ROOT/10-terminal/applications/codex-kitty-workflow.desktop"
do
  if [ -e "$path" ]; then
    emit_check terminal "$(basename "$path")-present" true ok "$path present"
  else
    emit_check terminal "$(basename "$path")-present" false degraded "$path missing"
    status=1
  fi
done

[ "$status" -eq 0 ] || exit "$status"

if sh -n \
  "$CODEX_ROOT/10-terminal/init.sh" \
  "$CODEX_ROOT/10-terminal/env.sh" \
  "$CODEX_ROOT/10-terminal/functions.sh" \
  "$CODEX_ROOT/10-terminal/bin/kitty-launch-desktop" && \
  grep -q 'include overrides.kitty.conf' "$CODEX_ROOT/10-terminal/kitty/kitty.conf"; then
  emit_check terminal terminal-load-order true ok "terminal stage files parse"
else
  emit_check terminal terminal-load-order false degraded "terminal stage parse failure"
  exit 1
fi

# Optional deeper check: do not make Kitty itself mandatory for rescue/bootstrap.
if command -v kitty >/dev/null 2>&1; then
  if kitty --debug-config --config "$CODEX_ROOT/10-terminal/kitty/kitty.conf" >/dev/null 2>&1; then
    emit_check terminal kitty-debug-config true ok "kitty debug config accepted"
  else
    emit_check terminal kitty-debug-config false degraded "kitty debug config failed"
    exit 1
  fi
else
  emit_check terminal kitty-available false warning "kitty not found on PATH; skipped debug config"
fi
