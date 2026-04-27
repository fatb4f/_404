#!/usr/bin/env bash
set -euo pipefail

json_mode=false
paths=()

while (($# > 0)); do
	case "$1" in
	--json)
		json_mode=true
		;;
	--)
		shift
		paths+=("$@")
		break
		;;
	*)
		paths+=("$1")
		;;
	esac
	shift
done

if ((${#paths[@]} == 0)); then
	mapfile -t paths < <(
		find "$HOME/.config/shell" -type f -name '*.sh' 2>/dev/null | sort
	)
fi

shellcheck_paths=("${paths[@]}")
shfmt_paths=()
hardening_paths=()
for f in "${paths[@]}"; do
	case "$f" in
	*.sh)
		case "$f" in
		*/test/*) ;;
		*)
			shfmt_paths+=("$f")
			hardening_paths+=("$f")
			;;
		esac
		;;
	esac
done

tool_present() {
	command -v "$1" >/dev/null 2>&1
}

run_shellcheck() {
	shellcheck_ok_state=null

	if tool_present shellcheck; then
		if ((${#shellcheck_paths[@]} == 0)); then
			shellcheck_ok_state=true
			return 0
		fi

		shellcheck -x "${shellcheck_paths[@]}"
		shellcheck_ok_state=true
		return 0
	fi

	printf 'missing shellcheck\n' >&2
	return 1
}

run_shfmt() {
	shfmt_ok_state=null

	if tool_present shfmt; then
		if ((${#shfmt_paths[@]} == 0)); then
			shfmt_ok_state=true
			return 0
		fi

		shfmt -d "${shfmt_paths[@]}" >/dev/null
		shfmt_ok_state=true
		return 0
	fi

	printf 'missing shfmt\n' >&2
	return 1
}

run_shellharden() {
	shellharden_ok_state=null

	if tool_present shellharden; then
		local f
		local status=0
		for f in "${hardening_paths[@]}"; do
			case "$(head -n 1 "$f" 2>/dev/null || true)" in
			'#!'*)
				if ! shellharden --transform "$f" >/dev/null; then
					status=1
				fi
				;;
			esac
		done
		if ((status == 0)); then
			shellharden_ok_state=true
		else
			shellharden_ok_state=false
			if ! $json_mode; then
				printf 'warn: shellharden failed\n' >&2
			fi
		fi
		return 0
	fi

	shellharden_ok_state=null
	if ! $json_mode; then
		printf 'warn: shellharden missing\n' >&2
	fi
	return 0
}

run_bats() {
	local bats_file="$HOME/.config/shell/test/bats/tier0.bats"
	bats_ok_state=null

	if tool_present bats; then
		if bats "$bats_file"; then
			bats_ok_state=true
		else
			bats_ok_state=false
			if ! $json_mode; then
				printf 'warn: bats failed\n' >&2
			fi
		fi
		return 0
	fi

	bats_ok_state=null
	if ! $json_mode; then
		printf 'warn: bats missing\n' >&2
	fi
	return 0
}

run_shellspec() {
	local shellspec_dir="$HOME/.config/shell/test/shellspec"
	shellspec_ok_state=null

	if tool_present shellspec; then
		if shellspec "$shellspec_dir"; then
			shellspec_ok_state=true
		else
			shellspec_ok_state=false
			if ! $json_mode; then
				printf 'warn: shellspec failed\n' >&2
			fi
		fi
		return 0
	fi

	shellspec_ok_state=null
	if ! $json_mode; then
		printf 'warn: shellspec missing\n' >&2
	fi
	return 0
}

emit_json() {
	local shellcheck_present shellcheck_ok
	local shfmt_present shfmt_ok
	local shellharden_present shellharden_ok
	local bats_present bats_ok
	local shellspec_present shellspec_ok

	if tool_present shellcheck; then
		shellcheck_present=true
		shellcheck_ok="${shellcheck_ok_state:-true}"
	else
		shellcheck_present=false
		shellcheck_ok=null
	fi

	if tool_present shfmt; then
		shfmt_present=true
		shfmt_ok="${shfmt_ok_state:-true}"
	else
		shfmt_present=false
		shfmt_ok=null
	fi

	if tool_present shellharden; then
		shellharden_present=true
		shellharden_ok="${shellharden_ok_state:-true}"
	else
		shellharden_present=false
		shellharden_ok=null
	fi

	if tool_present bats; then
		bats_present=true
		bats_ok="${bats_ok_state:-true}"
	else
		bats_present=false
		bats_ok=null
	fi

	if tool_present shellspec; then
		shellspec_present=true
		shellspec_ok="${shellspec_ok_state:-true}"
	else
		shellspec_present=false
		shellspec_ok=null
	fi

	jq -n \
		--arg schema 'shell.lint.observed.v0' \
		--argjson shellcheck_present "$shellcheck_present" \
		--argjson shellcheck_required true \
		--argjson shellcheck_ok "$shellcheck_ok" \
		--argjson shfmt_present "$shfmt_present" \
		--argjson shfmt_required true \
		--argjson shfmt_ok "$shfmt_ok" \
		--argjson shellharden_present "$shellharden_present" \
		--argjson shellharden_required false \
		--argjson shellharden_ok "$shellharden_ok" \
		--argjson bats_present "$bats_present" \
		--argjson bats_required false \
		--argjson bats_ok "$bats_ok" \
		--argjson shellspec_present "$shellspec_present" \
		--argjson shellspec_required false \
		--argjson shellspec_ok "$shellspec_ok" \
		--argjson syntax_bash true \
		--argjson syntax_zsh true \
		--argjson tier0_ok true \
		'{
			schema: $schema,
			tools: {
				shellcheck: {
					present: $shellcheck_present,
					required: $shellcheck_required,
					ok: $shellcheck_ok
				},
				shfmt: {
					present: $shfmt_present,
					required: $shfmt_required,
					ok: $shfmt_ok
				},
				shellharden: {
					present: $shellharden_present,
					required: $shellharden_required,
					ok: $shellharden_ok
				},
				bats: {
					present: $bats_present,
					required: $bats_required,
					ok: $bats_ok
				},
				shellspec: {
					present: $shellspec_present,
					required: $shellspec_required,
					ok: $shellspec_ok
				}
			},
			syntax: {
				bash: $syntax_bash,
				zsh: $syntax_zsh
			},
			tier0: {
				ok: $tier0_ok
			}
		}'
}

if $json_mode; then
	run_shellcheck
	run_shfmt
	run_shellharden
	run_bats
	run_shellspec
	emit_json
	exit 0
fi

run_shellcheck
printf 'shellcheck: ok\n'

run_shfmt
printf 'shfmt: ok\n'

run_shellharden
run_bats
run_shellspec

printf 'tier0 shell lint passed\n'
