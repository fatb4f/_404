#!/usr/bin/env sh
# codex agent stage init

: "${CODEX_AGENT_PREFIX:=${CODEX_ROOT:-${XDG_DATA_HOME:-$HOME/.local/share}/_404/current}}"

bootstrap_state="${CODEX_BOOTSTRAP_STATE:-${XDG_STATE_HOME:-$HOME/.local/state}/_404/bootstrap}"
[ -f "$bootstrap_state/20-agent.ready" ] || return 0 2>/dev/null || exit 0

[ -r "$CODEX_AGENT_PREFIX/20-agent/env.sh" ] && . "$CODEX_AGENT_PREFIX/20-agent/env.sh"
[ -r "$CODEX_AGENT_PREFIX/20-agent/functions.sh" ] && . "$CODEX_AGENT_PREFIX/20-agent/functions.sh"
