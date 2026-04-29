#!/usr/bin/env sh
# stage shell root helpers
# Sourced by $STAGE_ROOT/00-shell/init.sh. Keep path resolution strict.

relpath_ok() {
  case "$1" in
    ""|/*|*../*|../*) return 1 ;;
    *) return 0 ;;
  esac
}

require_file() {
  root=$1
  rel=$2

  relpath_ok "$rel" || return 2

  path="$root/$rel"
  [ -r "$path" ] || return 1
  printf '%s\n' "$path"
}

source_optional() {
  root=$1
  rel=$2

  path=$(require_file "$root" "$rel") || return 0
  . "$path"
}

source_required() {
  root=$1
  rel=$2

  path=$(require_file "$root" "$rel") || return 1
  . "$path"
}
