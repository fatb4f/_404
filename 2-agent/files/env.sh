#!/usr/bin/env sh
# codex agent env

: "${XDG_DATA_HOME:=${HOME}/.local/share}"
: "${XDG_STATE_HOME:=${HOME}/.local/state}"

# Runtime code should resolve from XDG-derived state, not from the source repo.
: "${CODEX_AGENT_PREFIX:=${CODEX_AGENT_PREFIX:-${CODEX_ROOT:-$XDG_DATA_HOME/_404/current}}}"

export CODEX_AGENT_PREFIX
export CODEX_AGENT_STATE="${CODEX_AGENT_STATE:-$XDG_STATE_HOME/_404/agent}"
export CODEX_AGENT_LOG="${CODEX_AGENT_LOG:-$CODEX_AGENT_STATE/agent.log}"
export CODEX_AGENT_MODE="${CODEX_AGENT_MODE:-noninteractive}"
export CODEX_BOOTSTRAP_STATE="${CODEX_BOOTSTRAP_STATE:-$XDG_STATE_HOME/_404/bootstrap}"
