# shellcheck shell=bash

dotctl_git_handler() {
  local repo="${1:?missing git repo}"
  shift

  command -v git >/dev/null 2>&1 || {
    printf 'missing required command: git\n' >&2
    return 1
  }

  git -C "$repo" "$@"
}

dotctl_git_status_porcelain() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" status --porcelain=v1 --branch --untracked-files=all --ignored
}

dotctl_git_ls_files_z() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" ls-files -z --full-name
}

dotctl_git_ls_files() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" ls-files
}

dotctl_git_ls_files_error_unmatch() {
  local repo="${1:?missing git repo}"
  local path="${2:?missing path}"

  dotctl_git_handler "$repo" ls-files --error-unmatch "$path" >/dev/null 2>&1
}

dotctl_git_rev_parse_git_dir() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" rev-parse --git-dir
}

dotctl_git_rev_parse_toplevel() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" rev-parse --show-toplevel
}

dotctl_git_symbolic_branch() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" symbolic-ref -q --short HEAD
}

dotctl_git_upstream_ref() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true
}

dotctl_git_head_rev() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" rev-parse HEAD
}

dotctl_git_ahead_behind() {
  local repo="${1:?missing git repo}"

  dotctl_git_handler "$repo" rev-list --left-right --count 'HEAD...@{u}'
}

dotctl_git_add_paths() {
  local repo="${1:?missing git repo}"
  shift

  (($# > 0)) || {
    printf 'refusing git add with empty path list\n' >&2
    return 2
  }

  dotctl_git_handler "$repo" add -A -- "$@"
}
