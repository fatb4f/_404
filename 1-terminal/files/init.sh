#!/usr/bin/env sh
# codex terminal stage init

: "${CODEX_ROOT:?CODEX_ROOT is required}"

bootstrap_state="${CODEX_BOOTSTRAP_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/codex/bootstrap}"
[ -f "$bootstrap_state/10-terminal.ready" ] || return 0 2>/dev/null || exit 0

[ -r "$CODEX_ROOT/10-terminal/env.sh" ] && . "$CODEX_ROOT/10-terminal/env.sh"
[ -r "$CODEX_ROOT/10-terminal/functions.sh" ] && . "$CODEX_ROOT/10-terminal/functions.sh"
