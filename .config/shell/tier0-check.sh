#!/usr/bin/env bash
set -euo pipefail

root="${1:-$HOME/.config/shell}"

check_syntax() {
	bash -n "$root/load-env.sh"
	zsh -n "$root/load-env.sh"
	bash -n "$root/validate-env.sh"
	zsh -n "$root/validate-env.sh"

	for f in "$root"/env.d/*.sh; do
		bash -n "$f"
		zsh -n "$f"
	done

	bash -n "$root/tier0-check.sh"
	bash -n "$root/lint-shell.sh"
}

check_static() {
	if command -v shellcheck >/dev/null 2>&1; then
		shellcheck -s bash -x \
			"$root/load-env.sh" \
			"$root/validate-env.sh" \
			"$root"/env.d/*.sh \
			"$root/tier0-check.sh" \
			"$root/lint-shell.sh"
	else
		printf 'warn: shellcheck missing\n' >&2
	fi

	if command -v shfmt >/dev/null 2>&1; then
		shfmt -d \
			"$root/load-env.sh" \
			"$root/validate-env.sh" \
			"$root"/env.d/*.sh \
			"$root/tier0-check.sh" \
			"$root/lint-shell.sh" >/dev/null
	else
		printf 'warn: shfmt missing\n' >&2
	fi

	if command -v shellharden >/dev/null 2>&1; then
		shellharden --transform "$root/load-env.sh" >/dev/null
		shellharden --transform "$root/validate-env.sh" >/dev/null
		for f in "$root"/env.d/*.sh; do
			shellharden --transform "$f" >/dev/null
		done
	else
		printf 'warn: shellharden missing\n' >&2
	fi
}

check_clean_bash() {
	# shellcheck disable=SC2016
	env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash bash --noprofile --norc -c '
    set -euo pipefail
    . "$HOME/.config/shell/load-env.sh"

    test -n "${XDG_CONFIG_HOME-}"
    test -n "${XDG_DATA_HOME-}"
    test -n "${XDG_STATE_HOME-}"
    test -n "${XDG_CACHE_HOME-}"
    test -n "${TOOL_PATH_HOME-}"
    test -n "${XDG_DATA_BIN-}"

    case ":$PATH:" in
      *":$TOOL_PATH_HOME:"*) ;;
      *) echo "TOOL_PATH_HOME missing from PATH" >&2; exit 1 ;;
    esac
  '
}

check_clean_zsh() {
	# shellcheck disable=SC2016
	env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/zsh zsh -f -c '
    . "$HOME/.config/shell/load-env.sh"

    test -n "${XDG_CONFIG_HOME-}"
    test -n "${XDG_DATA_HOME-}"
    test -n "${XDG_STATE_HOME-}"
    test -n "${XDG_CACHE_HOME-}"
    test -n "${TOOL_PATH_HOME-}"
    test -n "${XDG_DATA_BIN-}"

    case ":$PATH:" in
      *":$TOOL_PATH_HOME:"*) ;;
      *) print -ru2 -- "TOOL_PATH_HOME missing from PATH"; exit 1 ;;
    esac
  '
}

check_command_resolution() {
	# shellcheck disable=SC2016
	env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash bash --noprofile --norc -c '
    set -euo pipefail
    . "$HOME/.config/shell/load-env.sh"

    command -v dotctl >/dev/null
    command -v cue >/dev/null
    command -v just >/dev/null
    command -v yadm >/dev/null
    command -v git >/dev/null
  '
}

check_syntax
check_static
check_clean_bash
check_clean_zsh
check_command_resolution

printf '%s\n' 'tier0 shell stability passed'
