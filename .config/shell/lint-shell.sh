#!/usr/bin/env bash
set -euo pipefail

paths=("$@")

if ((${#paths[@]} == 0)); then
	mapfile -t paths < <(
		find \
			"$HOME/.config/shell" \
			"$HOME/.config/dotctl/src" \
			"$HOME/.config/yadm/bootstrap.d" \
			-type f \
			\( -name '*.sh' -o -perm -111 \) \
			2>/dev/null |
			sort
	)
fi

if command -v shellcheck >/dev/null 2>&1; then
	shellcheck -x "${paths[@]}"
else
	printf 'missing shellcheck\n' >&2
	exit 1
fi

if command -v shfmt >/dev/null 2>&1; then
	shfmt -d "${paths[@]}" >/dev/null
else
	printf 'missing shfmt\n' >&2
	exit 1
fi

if command -v shellharden >/dev/null 2>&1; then
	for f in "${paths[@]}"; do
		case "$(head -n 1 "$f" 2>/dev/null || true)" in
		'#!'*) shellharden --transform "$f" >/dev/null ;;
		esac
	done
else
	printf 'warn: shellharden missing\n' >&2
fi
