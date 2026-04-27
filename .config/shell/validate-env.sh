#!/usr/bin/env bash
set -euo pipefail

root="${1:-$HOME/.config/shell}"

bash -n "$root/load-env.sh"
zsh -n "$root/load-env.sh"

for f in "$root"/env.d/*.sh; do
	bash -n "$f"
	zsh -n "$f"
done

# shellcheck disable=SC2016
env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash bash --noprofile --norc -c '
  . "$HOME/.config/shell/load-env.sh"

  env | grep -E "(_404|/home/_404)" && exit 1

  test "${TOOL_PATH_HOME-}" = "${XDG_DATA_HOME}/path"
  test "${XDG_DATA_BIN-}" = "$HOME/.local/bin"
  test "${DIR_BOOTSTRAP-}" = "${XDG_DATA_HOME}/src/bootstrap"

  case ":$PATH:" in
    *":$TOOL_PATH_HOME:"*) ;;
    *) echo "TOOL_PATH_HOME missing from PATH" >&2; exit 1 ;;
  esac
'

# shellcheck disable=SC2016
env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/zsh zsh -f -c '
  . "$HOME/.config/shell/load-env.sh"

  env | grep -E "(_404|/home/_404)" && exit 1

  test "${TOOL_PATH_HOME-}" = "${XDG_DATA_HOME}/path"
  test "${XDG_DATA_BIN-}" = "$HOME/.local/bin"
  test "${DIR_BOOTSTRAP-}" = "${XDG_DATA_HOME}/src/bootstrap"

  case ":$PATH:" in
    *":$TOOL_PATH_HOME:"*) ;;
    *) print -ru2 -- "TOOL_PATH_HOME missing from PATH"; exit 1 ;;
  esac
'

"$root/check-env-ownership.py" "$root"
bash "$root/tier0-check.sh" "$root"

echo "shell env validation passed"
