#!/usr/bin/env sh
# stage terminal stage init

: "${STAGE_ROOT:?STAGE_ROOT is required}"

bootstrap_state="${BOOTSTRAP_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/_404/bootstrap}"
[ -f "$bootstrap_state/10-terminal.ready" ] || return 0 2>/dev/null || exit 0

[ -r "$STAGE_ROOT/10-terminal/env.sh" ] && . "$STAGE_ROOT/10-terminal/env.sh"
[ -r "$STAGE_ROOT/10-terminal/functions.sh" ] && . "$STAGE_ROOT/10-terminal/functions.sh"
