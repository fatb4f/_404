#!/usr/bin/env bash
set -euo pipefail

yadm_repo_dir() {
  printf '%s\n' "${YADM_REPO:-${XDG_DATA_HOME:-$HOME/.local/share}/yadm/repo.git}"
}

import_home_tree() {
  local project_root=${1:?project_root}
  local source_home="$project_root/home"

  [[ -d "$source_home" ]] || die "home overlay not found: $source_home"
  require_cmd rsync || die 'rsync is required to import the home overlay'

  info "importing direct-home overlay from $source_home into $HOME"
  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] rsync -a --exclude .git %q/ %q/\n' "$source_home" "$HOME"
  else
    rsync -a --exclude .git "$source_home/" "$HOME/"
  fi
}

activate_dotfiles() {
  local project_root=${1:?project_root}
  local repo_url=${DOTFILES_REPO_URL:-}
  local repo_dir
  repo_dir="$(yadm_repo_dir)"

  if [[ "${DRY_RUN:-0}" != 1 ]]; then
    require_cmd yadm || die 'yadm is required for direct $HOME dotfile tracking'
  elif ! command -v yadm >/dev/null 2>&1; then
    warn 'yadm not found; dry-run continues'
  fi

  if [[ "${IMPORT_HOME_TREE:-0}" == 1 ]]; then
    import_home_tree "$project_root"
  fi

  if [[ -d "$repo_dir" ]]; then
    info 'yadm repo exists; pulling dotfiles'
    run yadm pull --ff-only
    return 0
  fi

  if [[ -z "$repo_url" ]]; then
    warn 'no yadm repo found and DOTFILES_REPO_URL is unset; skipping clone'
    warn 'set DOTFILES_REPO_URL=<repo-url> or run yadm init/clone manually'
    return 0
  fi

  info "cloning dotfiles into direct HOME tracking: $repo_url"
  run yadm clone "$repo_url"
}
