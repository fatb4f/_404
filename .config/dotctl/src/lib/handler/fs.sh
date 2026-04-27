# shellcheck shell=bash

dotctl_fs_mktemp_dir() {
  command -v mktemp >/dev/null 2>&1 || {
    printf 'missing required command: mktemp\n' >&2
    return 1
  }

  mktemp -d
}

dotctl_fs_mkdir_p() {
  command -v mkdir >/dev/null 2>&1 || {
    printf 'missing required command: mkdir\n' >&2
    return 1
  }

  mkdir -p "$@"
}

dotctl_fs_rm_rf() {
  command -v rm >/dev/null 2>&1 || {
    printf 'missing required command: rm\n' >&2
    return 1
  }

  rm -rf "$@"
}

dotctl_fs_cp() {
  command -v cp >/dev/null 2>&1 || {
    printf 'missing required command: cp\n' >&2
    return 1
  }

  cp "$@"
}

dotctl_fs_mv() {
  command -v mv >/dev/null 2>&1 || {
    printf 'missing required command: mv\n' >&2
    return 1
  }

  mv "$@"
}

dotctl_fs_install() {
  command -v install >/dev/null 2>&1 || {
    printf 'missing required command: install\n' >&2
    return 1
  }

  install "$@"
}

dotctl_fs_ln_sfn() {
  command -v ln >/dev/null 2>&1 || {
    printf 'missing required command: ln\n' >&2
    return 1
  }

  ln -sfn "$@"
}

dotctl_tool_exists() {
  local tool="${1:?missing tool name}"

  command -v "$tool" >/dev/null 2>&1
}
