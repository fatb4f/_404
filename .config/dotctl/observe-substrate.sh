#!/usr/bin/env bash
set -euo pipefail

: "${HOME:?HOME is required}"
: "${XDG_CONFIG_HOME:=$HOME/.config}"

root="$XDG_CONFIG_HOME/dotctl"

relpath() {
  local path="$1"
  printf '%s\n' "${path#"$HOME"/}"
}

command_obs() {
  local path="$1"
  local rel="$2"
  local exists=false
  local thin=false
  local line_count=0

  if [[ -e "$path" ]]; then
    exists=true
    line_count="$(wc -l < "$path" | tr -d ' ')"
    if [[ "$line_count" -le 6 ]]; then
      thin=true
    fi
  fi

  jq -n \
    --arg path "$rel" \
    --argjson exists "$exists" \
    --argjson thin "$thin" \
    --argjson line_count "$line_count" \
    '{path: $path, exists: $exists, thin: $thin, line_count: $line_count}'
}

lib_obs() {
  local path="$1"
  local rel="$2"
  local exists=false

  if [[ -e "$path" ]]; then
    exists=true
  fi

  jq -n \
    --arg path "$rel" \
    --argjson exists "$exists" \
    '{path: $path, exists: $exists}'
}

syntax_failures_json='{}'
syntax_paths=(
  "$root/src/audit_command.sh"
  "$root/src/check_command.sh"
  "$root/src/status_command.sh"
  "$root/src/bootstrap_command.sh"
  "$root/src/provision_command.sh"
  "$root/src/lib/env.sh"
  "$root/src/lib/audit.sh"
  "$root/src/lib/check.sh"
  "$root/src/lib/yadm.sh"
)

for path in "${syntax_paths[@]}"; do
  if [[ -f "$path" ]] && ! bash -n "$path" >/dev/null 2>&1; then
    syntax_failures_json="$(
      jq -n \
        --argjson prev "$syntax_failures_json" \
        --arg path "${path#"$HOME"/}" \
        --arg error "bash -n failed" \
        '$prev + {($path): $error}'
    )"
  fi
done

audit_cmd="$(command_obs "$root/src/audit_command.sh" "$(relpath "$root/src/audit_command.sh")")"
check_cmd="$(command_obs "$root/src/check_command.sh" "$(relpath "$root/src/check_command.sh")")"
status_cmd="$(command_obs "$root/src/status_command.sh" "$(relpath "$root/src/status_command.sh")")"
bootstrap_cmd="$(command_obs "$root/src/bootstrap_command.sh" "$(relpath "$root/src/bootstrap_command.sh")")"
provision_cmd="$(command_obs "$root/src/provision_command.sh" "$(relpath "$root/src/provision_command.sh")")"

env_lib="$(lib_obs "$root/src/lib/env.sh" "$(relpath "$root/src/lib/env.sh")")"
audit_lib="$(lib_obs "$root/src/lib/audit.sh" "$(relpath "$root/src/lib/audit.sh")")"
check_lib="$(lib_obs "$root/src/lib/check.sh" "$(relpath "$root/src/lib/check.sh")")"
yadm_lib="$(lib_obs "$root/src/lib/yadm.sh" "$(relpath "$root/src/lib/yadm.sh")")"

generated_dotctl=false
generated_bin_dotctl=false
[[ -e "$root/dotctl" ]] && generated_dotctl=true
[[ -e "$root/bin/dotctl" ]] && generated_bin_dotctl=true

jq -n \
  --arg schema "dotctl.substrate.observed.v0" \
  --argjson commands "$(jq -n \
    --argjson audit "$audit_cmd" \
    --argjson check "$check_cmd" \
    --argjson status "$status_cmd" \
    --argjson bootstrap "$bootstrap_cmd" \
    --argjson provision "$provision_cmd" \
    '{audit:$audit,check:$check,status:$status,bootstrap:$bootstrap,provision:$provision}')" \
  --argjson libs "$(jq -n \
    --argjson env "$env_lib" \
    --argjson audit "$audit_lib" \
    --argjson check "$check_lib" \
    --argjson yadm "$yadm_lib" \
    '{env:$env,audit:$audit,check:$check,yadm:$yadm}')" \
  --argjson generated "$(jq -n \
    --argjson dotctl "$generated_dotctl" \
    --argjson bin_dotctl "$generated_bin_dotctl" \
    '{".config/dotctl/dotctl": $dotctl, ".config/dotctl/bin/dotctl": $bin_dotctl}')" \
  --argjson syntax_failures "$syntax_failures_json" \
  '{
    schema: $schema,
    commands: $commands,
    libs: $libs,
    generated: $generated,
    syntax_failures: $syntax_failures
  }'
