#!/usr/bin/env bash
set -euo pipefail

doctor() {
  local project_root=${1:?project_root}
  local host_class=${2:?host_class}
  local failures=0
  local local_bin=${_404_LOCAL_BIN:-$HOME/.local/bin}

  printf 'host_class=%s\n' "$host_class"
  printf 'home=%s\n' "$HOME"
  printf 'xdg_config_home=%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"
  printf 'xdg_data_home=%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
  printf 'local_bin=%s\n' "$local_bin"

  local cmd
  for cmd in bash git curl jq gh npm yadm zsh chsh; do
    if command -v "$cmd" >/dev/null 2>&1; then
      printf 'ok command %s -> %s\n' "$cmd" "$(command -v "$cmd")"
    else
      printf 'missing command %s\n' "$cmd"
      if [[ "${DRY_RUN:-0}" != 1 ]]; then
        failures=$((failures + 1))
      fi
    fi
  done

  if [[ -d "$local_bin" ]]; then
    printf 'ok local_bin exists\n'
  else
    printf 'missing local_bin directory\n'
    if [[ "${DRY_RUN:-0}" != 1 ]]; then
      failures=$((failures + 1))
    fi
  fi

  local legacy_count
  legacy_count="$(find "$project_root/home" -type f \
    \( -name 'dot_*' -o -name 'executable_*' -o -name 'readonly_*' -o -name 'empty_*' \) \
    2>/dev/null | wc -l | tr -d ' ')"
  if [[ "$legacy_count" == 0 ]]; then
    printf 'ok direct-home filenames: no chezmoi source prefixes under home/\n'
  else
    printf 'fail direct-home filenames: %s legacy chezmoi-style names remain under home/\n' "$legacy_count"
    failures=$((failures + 1))
  fi

  if [[ -r "$project_root/home/.zshenv" && -r "$project_root/home/.config/zsh/.zshenv" && -r "$project_root/home/.config/zsh/.zshrc" ]]; then
    printf 'ok zsh dotfiles exist in home overlay\n'
  else
    printf 'warn zsh dotfiles missing from home overlay\n'
  fi

  if command -v yadm >/dev/null 2>&1; then
    yadm status --short || true
  fi

  if ((failures > 0)); then
    printf 'doctor_failures=%s\n' "$failures"
    return 1
  fi

  printf 'doctor_ok=1\n'
}
