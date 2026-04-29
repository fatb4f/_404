#!/usr/bin/env sh
# codex stage 0 init
# Sourced from $CODEX_ROOT/00-shell/init.sh.

: "${CODEX_ROOT:?CODEX_ROOT is required}"

bootstrap_state="${CODEX_BOOTSTRAP_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/codex/bootstrap}"
[ -f "$bootstrap_state/00-shell.ready" ] || return 0 2>/dev/null || exit 0

[ -r "$CODEX_ROOT/00-shell/require.sh" ] && . "$CODEX_ROOT/00-shell/require.sh"
[ -r "$CODEX_ROOT/00-shell/env.sh" ] && . "$CODEX_ROOT/00-shell/env.sh"
[ -r "$CODEX_ROOT/00-shell/path.sh" ] && . "$CODEX_ROOT/00-shell/path.sh"
