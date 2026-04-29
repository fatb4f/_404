#!/usr/bin/env sh
# codex shell root helpers
# Sourced by $CODEX_ROOT/00-shell/init.sh. Keep path resolution strict.

codex_relpath_ok() {
  case "$1" in
    ""|/*|*../*|../*) return 1 ;;
    *) return 0 ;;
  esac
}

codex_require_file() {
  root=$1
  rel=$2

  codex_relpath_ok "$rel" || return 2

  path="$root/$rel"
  [ -r "$path" ] || return 1
  printf '%s\n' "$path"
}

codex_source_optional() {
  root=$1
  rel=$2

  path=$(codex_require_file "$root" "$rel") || return 0
  . "$path"
}

codex_source_required() {
  root=$1
  rel=$2

  path=$(codex_require_file "$root" "$rel") || return 1
  . "$path"
}
