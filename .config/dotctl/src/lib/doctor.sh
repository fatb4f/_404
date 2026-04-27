# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/cue.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/fs.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/jq.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/kitty.sh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/yadm.sh"

dotctl_doctor_probe_shell_env() {
  local status="missing"
  local message="managed shell env not loaded"

  if [[ -n "${XDG_CONFIG_HOME:-}" && -n "${XDG_DATA_HOME:-}" && -n "${XDG_STATE_HOME:-}" && -n "${XDG_CACHE_HOME:-}" && -n "${TOOL_PATH_HOME:-}" ]]; then
    case ":${PATH:-}:" in
      *":$TOOL_PATH_HOME:"*|*":${XDG_DATA_BIN:-}:"*)
        status="ok"
        message="managed shell env loaded"
        ;;
      *)
        status="missing"
        message="managed PATH projection missing"
        ;;
    esac
  fi

  printf '%s\t%s\n' "$status" "$message"
}

dotctl_doctor_probe_shell_path() {
  local required=(
    dotctl
    cue
    just
    yadm
    git
    bash
    zsh
  )
  local missing=()
  local cmd

  for cmd in "${required[@]}"; do
    if ! dotctl_tool_exists "$cmd"; then
      missing+=("$cmd")
    fi
  done

  if ((${#missing[@]} == 0)); then
    printf '%s\t%s\n' ok "required managed commands resolve"
  else
    printf '%s\t%s\n' missing "missing commands: ${missing[*]}"
  fi
}

dotctl_doctor_probe_tool() {
  local cmd="${1:?cmd}"
  local label="${2:-$1}"

  if dotctl_tool_exists "$cmd"; then
    printf '%s\t%s\n' ok "$label resolves"
  else
    printf '%s\t%s\n' missing "$label not on PATH"
  fi
}

dotctl_doctor_probe_terminal_kitty() {
  if ! dotctl_tool_exists kitty; then
    printf '%s\t%s\n' missing "Kitty executable is not available from current managed PATH"
    return 0
  fi

  if dotctl_kitty_version >/dev/null 2>&1; then
    printf '%s\t%s\n' ok "kitty resolves and reports version"
  else
    printf '%s\t%s\n' degraded "kitty executable resolves but version probe failed"
  fi
}

dotctl_doctor_probe_terminal_kitty_session() {
  if [[ -n "${KITTY_WINDOW_ID:-}" || -n "${KITTY_PID:-}" ]]; then
    if [[ -n "${TERM:-}" ]]; then
      printf '%s\t%s\n' ok "kitty session environment present"
    else
      printf '%s\t%s\n' warning "kitty session detected but TERM is empty"
    fi
    return 0
  fi

  if [[ -n "${TERM:-}" ]]; then
    printf '%s\t%s\n' warning "not running inside a Kitty session"
  else
    printf '%s\t%s\n' warning "kitty session unavailable and TERM is empty"
  fi
}

dotctl_doctor_probe_backend_yadm() {
  if dotctl_yadm_status >/dev/null 2>&1; then
    printf '%s\t%s\n' ok "backend status available"
  else
    printf '%s\t%s\n' missing "backend unavailable"
  fi
}

dotctl_doctor_run() {
  local json_mode="${1:-false}"
  local shell_env shell_path tool_dotctl tool_cue tool_just backend_yadm terminal_kitty terminal_kitty_session tier0_shell policy_audit precommit_shell_lint
  local shell_env_status shell_env_message
  local shell_path_status shell_path_message
  local tool_dotctl_status tool_dotctl_message
  local tool_cue_status tool_cue_message
  local tool_just_status tool_just_message
  local backend_yadm_status backend_yadm_message
  local terminal_kitty_status terminal_kitty_message
  local terminal_kitty_session_status terminal_kitty_session_message
  local tier0_shell_status tier0_shell_message
  local policy_audit_status policy_audit_message
  local precommit_shell_lint_status precommit_shell_lint_message
  local doctor_json

  IFS=$'\t' read -r shell_env_status shell_env_message < <(dotctl_doctor_probe_shell_env)
  IFS=$'\t' read -r shell_path_status shell_path_message < <(dotctl_doctor_probe_shell_path)
  IFS=$'\t' read -r tool_dotctl_status tool_dotctl_message < <(dotctl_doctor_probe_tool dotctl "dotctl")
  IFS=$'\t' read -r tool_cue_status tool_cue_message < <(dotctl_doctor_probe_tool cue "cue")
  IFS=$'\t' read -r tool_just_status tool_just_message < <(dotctl_doctor_probe_tool just "just")
  IFS=$'\t' read -r backend_yadm_status backend_yadm_message < <(dotctl_doctor_probe_backend_yadm)
  IFS=$'\t' read -r terminal_kitty_status terminal_kitty_message < <(dotctl_doctor_probe_terminal_kitty)
  IFS=$'\t' read -r terminal_kitty_session_status terminal_kitty_session_message < <(dotctl_doctor_probe_terminal_kitty_session)

  if [[ "$shell_env_status" == ok && "$shell_path_status" == ok ]]; then
    tier0_shell_status=ok
    tier0_shell_message="tier0 shell substrate is recoverable"
  else
    tier0_shell_status=missing
    tier0_shell_message="tier0 shell substrate is degraded"
  fi

  if [[ "$tool_dotctl_status" == ok && "$tool_cue_status" == ok && "$backend_yadm_status" == ok ]]; then
    policy_audit_status=ok
    policy_audit_message="policy audit substrate is present"
  else
    policy_audit_status=missing
    policy_audit_message="policy audit substrate is degraded"
  fi

  if [[ "$tool_cue_status" == ok && "$tool_just_status" == ok && "$tier0_shell_status" == ok ]]; then
    precommit_shell_lint_status=ok
    precommit_shell_lint_message="precommit shell lint substrate is present"
  else
    precommit_shell_lint_status=missing
    precommit_shell_lint_message="precommit shell lint substrate is degraded"
  fi

  doctor_json="$(
    dotctl_jq -n \
      --arg schema 'dotctl.doctor.observed.v0' \
      --arg shell_env_status "$shell_env_status" \
      --arg shell_env_message "$shell_env_message" \
      --arg shell_path_status "$shell_path_status" \
      --arg shell_path_message "$shell_path_message" \
      --arg tool_dotctl_status "$tool_dotctl_status" \
      --arg tool_dotctl_message "$tool_dotctl_message" \
      --arg tool_cue_status "$tool_cue_status" \
      --arg tool_cue_message "$tool_cue_message" \
      --arg tool_just_status "$tool_just_status" \
      --arg tool_just_message "$tool_just_message" \
      --arg backend_yadm_status "$backend_yadm_status" \
      --arg backend_yadm_message "$backend_yadm_message" \
      --arg terminal_kitty_status "$terminal_kitty_status" \
      --arg terminal_kitty_message "$terminal_kitty_message" \
      --arg terminal_kitty_session_status "$terminal_kitty_session_status" \
      --arg terminal_kitty_session_message "$terminal_kitty_session_message" \
      --arg tier0_shell_status "$tier0_shell_status" \
      --arg tier0_shell_message "$tier0_shell_message" \
      --arg policy_audit_status "$policy_audit_status" \
      --arg policy_audit_message "$policy_audit_message" \
      --arg precommit_shell_lint_status "$precommit_shell_lint_status" \
      --arg precommit_shell_lint_message "$precommit_shell_lint_message" \
      '{
        schema: $schema,
        services: {
          "terminal.kitty": {
            dependsOn: [],
            severity: "degraded",
            status: $terminal_kitty_status,
            message: $terminal_kitty_message
          },
          "shell.env": {
            dependsOn: [],
            severity: "critical",
            status: $shell_env_status,
            message: $shell_env_message
          },
          "shell.path": {
            dependsOn: ["shell.env"],
            severity: "critical",
            status: $shell_path_status,
            message: $shell_path_message
          },
          "terminal.kitty-session": {
            dependsOn: ["terminal.kitty", "shell.env"],
            severity: "warning",
            status: $terminal_kitty_session_status,
            message: $terminal_kitty_session_message
          },
          "tool.dotctl": {
            dependsOn: ["shell.path"],
            severity: "critical",
            status: $tool_dotctl_status,
            message: $tool_dotctl_message
          },
          "tool.cue": {
            dependsOn: ["shell.path"],
            severity: "critical",
            status: $tool_cue_status,
            message: $tool_cue_message
          },
          "tool.just": {
            dependsOn: ["shell.path"],
            severity: "critical",
            status: $tool_just_status,
            message: $tool_just_message
          },
          "backend.yadm": {
            dependsOn: ["shell.path"],
            severity: "critical",
            status: $backend_yadm_status,
            message: $backend_yadm_message
          },
          "tier0.shell": {
            dependsOn: ["shell.env"],
            severity: "critical",
            status: $tier0_shell_status,
            message: $tier0_shell_message
          },
          "policy.audit": {
            dependsOn: ["tool.dotctl", "tool.cue", "backend.yadm"],
            severity: "critical",
            status: $policy_audit_status,
            message: $policy_audit_message
          },
          "precommit.shell-lint": {
            dependsOn: ["tool.cue", "tool.just", "tier0.shell"],
            severity: "critical",
            status: $precommit_shell_lint_status,
            message: $precommit_shell_lint_message
          }
        }
      }'
  )"

  if [[ -n "$json_mode" && "$json_mode" != 0 && "$json_mode" != false ]]; then
    printf '%s\n' "$doctor_json"
    return 0
  fi

  printf '%s\n' "doctor graph"
  dotctl_jq -r '
    .services
    | to_entries[]
    | "\(.key)\t\(.value.status)\t\(.value.severity)\t\(.value.message)"
  ' <<<"$doctor_json"
}
