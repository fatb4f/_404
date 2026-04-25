#!/usr/bin/env bash
set -Eeuo pipefail
shopt -s inherit_errexit 2>/dev/null || true

usage() {
  cat <<'EOF'
Usage: script-name [options] [args]

Options:
  -h, --help    Show this help text
EOF
}

log() {
  local level=$1
  shift
  printf '[%s] %s\n' "$level" "$*" >&2
}

cleanup() {
  :
}

trap cleanup EXIT
trap 'log ERROR "failed at line $LINENO"; exit 1' ERR

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h | --help)
        usage
        return 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        log ERROR "unknown option: $1"
        usage
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  log INFO "starting"
}

main "$@"
