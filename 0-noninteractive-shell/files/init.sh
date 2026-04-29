#!/usr/bin/env sh
# stage stage 0 init
# Sourced from $STAGE_ROOT/00-shell/init.sh.

: "${STAGE_ROOT:?STAGE_ROOT is required}"

bootstrap_state="${BOOTSTRAP_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/_404/bootstrap}"
[ -f "$bootstrap_state/00-shell.ready" ] || return 0 2>/dev/null || exit 0

[ -r "$STAGE_ROOT/00-shell/require.sh" ] && . "$STAGE_ROOT/00-shell/require.sh"
[ -r "$STAGE_ROOT/00-shell/env.sh" ] && . "$STAGE_ROOT/00-shell/env.sh"
[ -r "$STAGE_ROOT/00-shell/path.sh" ] && . "$STAGE_ROOT/00-shell/path.sh"
