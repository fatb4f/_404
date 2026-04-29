#!/usr/bin/env sh
# codex agent functions

shell_snapshot() {
  mkdir -p "${CODEX_AGENT_STATE:?}"
  snapshot="${CODEX_AGENT_STATE}/shell-snapshot.json"

  if command -v python3 >/dev/null 2>&1; then
    python3 - "$snapshot" "$CODEX_AGENT_PREFIX" "$CODEX_AGENT_STATE" "$CODEX_AGENT_MODE" "${SHELL:-}" "${PATH:-}" <<'PY'
import json
import sys

snapshot, agent_prefix, agent_state, agent_mode, shell, path = sys.argv[1:7]
data = {
    "agent_prefix": agent_prefix,
    "agent_state": agent_state,
    "mode": agent_mode,
    "shell": shell,
    "path": path,
}
with open(snapshot, "w", encoding="utf-8") as fh:
    json.dump(data, fh, sort_keys=True)
    fh.write("\n")
print(json.dumps(data, sort_keys=True))
PY
  else
    printf '{"agent_prefix":"%s","agent_state":"%s","mode":"%s","shell":"%s","path":"%s"}\n' \
      "${CODEX_AGENT_PREFIX:-}" \
      "$CODEX_AGENT_STATE" \
      "$CODEX_AGENT_MODE" \
      "${SHELL:-}" \
      "${PATH:-}" | tee "$snapshot"
  fi
}

shell_tool() {
  case "${1:-}" in
    --snapshot)
      shell_snapshot
      return 0
      ;;
    "")
      printf >&2 'usage: shell_tool [--snapshot] command [args...]\n'
      return 64
      ;;
  esac

  "$@"
}
