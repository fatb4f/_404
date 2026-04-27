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
  "$root/src/audit_observe_command.sh"
  "$root/src/audit_vet_command.sh"
  "$root/src/audit_run_command.sh"
  "$root/src/git_observe_command.sh"
  "$root/src/git_vet_command.sh"
  "$root/src/git_project_state_command.sh"
  "$root/src/git_refresh_command.sh"
  "$root/src/git_status_command.sh"
  "$root/src/git_add_command.sh"
  "$root/src/check_command.sh"
  "$root/src/status_command.sh"
  "$root/src/bootstrap_command.sh"
  "$root/src/provision_command.sh"
  "$root/src/lib/env.sh"
  "$root/src/lib/audit.sh"
  "$root/src/lib/git.sh"
  "$root/src/lib/check.sh"
  "$root/src/lib/yadm.sh"
  "$root/src/lib/handler/bashly.sh"
  "$root/src/lib/handler/cue.sh"
  "$root/src/lib/handler/fs.sh"
  "$root/src/lib/handler/git.sh"
  "$root/src/lib/handler/jq.sh"
  "$root/src/lib/handler/yadm.sh"
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

audit_observe_cmd="$(command_obs "$root/src/audit_observe_command.sh" "$(relpath "$root/src/audit_observe_command.sh")")"
audit_vet_cmd="$(command_obs "$root/src/audit_vet_command.sh" "$(relpath "$root/src/audit_vet_command.sh")")"
audit_run_cmd="$(command_obs "$root/src/audit_run_command.sh" "$(relpath "$root/src/audit_run_command.sh")")"
git_observe_cmd="$(command_obs "$root/src/git_observe_command.sh" "$(relpath "$root/src/git_observe_command.sh")")"
git_vet_cmd="$(command_obs "$root/src/git_vet_command.sh" "$(relpath "$root/src/git_vet_command.sh")")"
git_project_state_cmd="$(command_obs "$root/src/git_project_state_command.sh" "$(relpath "$root/src/git_project_state_command.sh")")"
git_refresh_cmd="$(command_obs "$root/src/git_refresh_command.sh" "$(relpath "$root/src/git_refresh_command.sh")")"
git_status_cmd="$(command_obs "$root/src/git_status_command.sh" "$(relpath "$root/src/git_status_command.sh")")"
git_add_cmd="$(command_obs "$root/src/git_add_command.sh" "$(relpath "$root/src/git_add_command.sh")")"
check_cmd="$(command_obs "$root/src/check_command.sh" "$(relpath "$root/src/check_command.sh")")"
status_cmd="$(command_obs "$root/src/status_command.sh" "$(relpath "$root/src/status_command.sh")")"
bootstrap_cmd="$(command_obs "$root/src/bootstrap_command.sh" "$(relpath "$root/src/bootstrap_command.sh")")"
provision_cmd="$(command_obs "$root/src/provision_command.sh" "$(relpath "$root/src/provision_command.sh")")"

env_lib="$(lib_obs "$root/src/lib/env.sh" "$(relpath "$root/src/lib/env.sh")")"
audit_lib="$(lib_obs "$root/src/lib/audit.sh" "$(relpath "$root/src/lib/audit.sh")")"
git_lib="$(lib_obs "$root/src/lib/git.sh" "$(relpath "$root/src/lib/git.sh")")"
check_lib="$(lib_obs "$root/src/lib/check.sh" "$(relpath "$root/src/lib/check.sh")")"
yadm_lib="$(lib_obs "$root/src/lib/yadm.sh" "$(relpath "$root/src/lib/yadm.sh")")"
handler_bashly_lib="$(lib_obs "$root/src/lib/handler/bashly.sh" "$(relpath "$root/src/lib/handler/bashly.sh")")"
handler_cue_lib="$(lib_obs "$root/src/lib/handler/cue.sh" "$(relpath "$root/src/lib/handler/cue.sh")")"
handler_fs_lib="$(lib_obs "$root/src/lib/handler/fs.sh" "$(relpath "$root/src/lib/handler/fs.sh")")"
handler_git_lib="$(lib_obs "$root/src/lib/handler/git.sh" "$(relpath "$root/src/lib/handler/git.sh")")"
handler_jq_lib="$(lib_obs "$root/src/lib/handler/jq.sh" "$(relpath "$root/src/lib/handler/jq.sh")")"
handler_yadm_lib="$(lib_obs "$root/src/lib/handler/yadm.sh" "$(relpath "$root/src/lib/handler/yadm.sh")")"

external_invocations_json='{}'
while IFS= read -r path; do
  [[ -f "$path" ]] || continue
  case "$path" in
    "$root/src/lib/handler/"*)
      continue
      ;;
  esac

  labels=()
  for regex in \
    '(^|[^[:alnum:]_])(git -C|cue vet|cue export|yadm[[:space:]]|bashly generate|jq[[:space:]]|command -v|mktemp|mv[[:space:]]|install[[:space:]]|ln -sfn)'
  do
    if grep -Eq "$regex" "$path"; then
      labels+=("$regex")
    fi
  done

  if ((${#labels[@]} > 0)); then
    external_invocations_json="$(
      jq -n \
        --argjson prev "$external_invocations_json" \
        --arg path "${path#"$HOME"/}" \
        --argjson labels "$(printf '%s\n' "${labels[@]}" | jq -Rsc 'split("\n")[:-1]')" \
        '$prev + {($path): $labels}'
    )"
  fi
done < <(find "$root/src" -type f -name '*.sh' | sort)

generated_dotctl=false
generated_bin_dotctl=false
[[ -e "$root/dotctl" ]] && generated_dotctl=true
[[ -e "$root/bin/dotctl" ]] && generated_bin_dotctl=true

jq -n \
  --arg schema "dotctl.substrate.observed.v0" \
  --argjson commands "$(jq -n \
    --argjson audit_observe "$audit_observe_cmd" \
    --argjson audit_vet "$audit_vet_cmd" \
    --argjson audit_run "$audit_run_cmd" \
    --argjson git_observe "$git_observe_cmd" \
    --argjson git_vet "$git_vet_cmd" \
    --argjson git_project_state "$git_project_state_cmd" \
    --argjson git_refresh "$git_refresh_cmd" \
    --argjson git_status "$git_status_cmd" \
    --argjson git_add "$git_add_cmd" \
    --argjson check "$check_cmd" \
    --argjson status "$status_cmd" \
    --argjson bootstrap "$bootstrap_cmd" \
    --argjson provision "$provision_cmd" \
    '{audit:{observe:$audit_observe,vet:$audit_vet,run:$audit_run},git:{observe:$git_observe,vet:$git_vet,project_state:$git_project_state,refresh:$git_refresh,status:$git_status,add:$git_add},check:$check,status:$status,bootstrap:$bootstrap,provision:$provision}')" \
  --argjson libs "$(jq -n \
    --argjson env "$env_lib" \
    --argjson audit "$audit_lib" \
    --argjson git "$git_lib" \
    --argjson check "$check_lib" \
    --argjson yadm "$yadm_lib" \
    --argjson handler_bashly "$handler_bashly_lib" \
    --argjson handler_cue "$handler_cue_lib" \
    --argjson handler_fs "$handler_fs_lib" \
    --argjson handler_git "$handler_git_lib" \
    --argjson handler_jq "$handler_jq_lib" \
    --argjson handler_yadm "$handler_yadm_lib" \
    '{env:$env,audit:$audit,git:$git,check:$check,yadm:$yadm,handler:{bashly:$handler_bashly,cue:$handler_cue,fs:$handler_fs,git:$handler_git,jq:$handler_jq,yadm:$handler_yadm}}')" \
  --argjson generated "$(jq -n \
    --argjson dotctl "$generated_dotctl" \
    --argjson bin_dotctl "$generated_bin_dotctl" \
    '{".config/dotctl/dotctl": $dotctl, ".config/dotctl/bin/dotctl": $bin_dotctl}')" \
  --argjson syntax_failures "$syntax_failures_json" \
  --argjson external_invocations "$external_invocations_json" \
  '{
    schema: $schema,
    commands: $commands,
    libs: $libs,
    external_invocations: $external_invocations,
    generated: $generated,
    syntax_failures: $syntax_failures
  }'
