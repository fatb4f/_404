#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)

find_repo_root() {
  dir=$1
  while [ "$dir" != "/" ]; do
    if [ -f "$dir/src/lib/fs.sh" ] && [ -f "$dir/src/lib/domain.sh" ]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

ROOT=$(find_repo_root "$script_dir")
DOMAIN_DIR="$script_dir"

. "$ROOT/src/lib/fs.sh"
. "$ROOT/src/lib/report.sh"
. "$ROOT/src/lib/domain.sh"

domain_check_from_generated "$ROOT" "$DOMAIN_DIR"
