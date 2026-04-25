#!/usr/bin/env bash
set -euo pipefail

zsh_dotfiles_are_live() {
  [[ -r "$HOME/.zshenv" ]] || [[ -r "$HOME/.config/zsh/.zshrc" ]]
}

set_login_shell_after_dotfiles() {
  local zsh_path current_shell

  zsh_path="$(command -v zsh 2>/dev/null || true)"
  if [[ -z "$zsh_path" ]]; then
    if [[ "${DRY_RUN:-0}" == 1 ]]; then
      zsh_path="/usr/bin/zsh"
      warn "zsh is not installed; dry-run uses $zsh_path"
    else
      die 'zsh is not installed; run the pkgs stage first'
    fi
  fi

  if [[ "${DRY_RUN:-0}" != 1 ]] && ! zsh_dotfiles_are_live; then
    warn 'zsh dotfiles are not live yet; skipping chsh'
    return 0
  fi

  current_shell="$(getent passwd "${USER:-$(id -un)}" 2>/dev/null | awk -F: '{print $7}' || true)"
  if [[ "$current_shell" == "$zsh_path" ]]; then
    info "login shell already set to $zsh_path"
    return 0
  fi

  if [[ -r /etc/shells ]] && ! grep -Fx -- "$zsh_path" /etc/shells >/dev/null 2>&1; then
    warn "$zsh_path is not listed in /etc/shells; chsh may fail"
  fi

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] chsh -s %q %q </dev/null\n' "$zsh_path" "${USER:-$(id -un)}"
    return 0
  fi

  if chsh -s "$zsh_path" "${USER:-$(id -un)}" </dev/null; then
    info "login shell set to $zsh_path"
    return 0
  fi

  if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
    if sudo -n chsh -s "$zsh_path" "${USER:-$(id -un)}" </dev/null; then
      info "login shell set to $zsh_path via sudo"
      return 0
    fi
  fi

  warn 'could not change login shell non-interactively; run manually after login if needed'
  warn "manual command: chsh -s '$zsh_path' '${USER:-$(id -un)}'"
}
