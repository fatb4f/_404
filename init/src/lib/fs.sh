#!/usr/bin/env sh
set -eu

# Root defaults. The repo-owned roots are intentionally separate from
# host-owned state/cache/activation roots.
root_dots_home() { printf '%s\n' "${DOTS_HOME:-$HOME/${DOTS_REPO:-src}/${DOTS_DIR:-dots}}"; }
xdg_config_home() { printf '%s\n' "${XDG_CONFIG_HOME:-$(root_dots_home)/.config}"; }
xdg_data_home() { printf '%s\n' "${XDG_DATA_HOME:-$(root_dots_home)/.local/share}"; }
xdg_opt_home() { printf '%s\n' "${XDG_OPT_HOME:-$(root_dots_home)/.local/opt}"; }
xdg_state_home() { printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}"; }
xdg_cache_home() { printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}"; }
tool_path_home() { printf '%s\n' "${TOOL_PATH_HOME:-$HOME/.local/bin}"; }
tool_prefix_home() {
  tp=$(tool_path_home)
  case "$tp" in
    */bin) dirname "$tp" ;;
    *) printf '%s\n' "$tp" ;;
  esac
}

bootstrap_state_dir() { printf '%s/_404/bootstrap\n' "$(xdg_state_home)"; }
stage_ready_path() { printf '%s/%s.ready\n' "$(bootstrap_state_dir)" "${1:?stage required}"; }

stage_require_ready() {
  marker=$(stage_ready_path "$1")
  [ -f "$marker" ] || {
    if [ "${DOMAIN_DRY_RUN:-${DRY_RUN:-0}}" -eq 1 ]; then
      printf '[dry-run] would require ready marker: %s\n' "$marker"
      return 0
    fi
    printf >&2 'missing ready marker: %s\n' "$marker"
    return 1
  }
}

stage_mark_ready() {
  marker=$(stage_ready_path "$1")
  if [ "${DOMAIN_DRY_RUN:-${DRY_RUN:-0}}" -eq 1 ]; then
    printf '[dry-run] would mark ready: %s\n' "$marker"
    return 0
  fi
  mkdir -p "$(dirname "$marker")"
  tmp="$(dirname "$marker")/.tmp.$(basename "$marker").$$"
  : >"$tmp"
  mv -f "$tmp" "$marker"
}

relpath_ok() {
  case "$1" in
    ""|/*|*../*|../*) return 1 ;;
    *) return 0 ;;
  esac
}

require_file() {
  root=$1
  rel=$2
  relpath_ok "$rel" || return 2
  path="$root/$rel"
  [ -r "$path" ] || return 1
  printf '%s\n' "$path"
}

atomic_copy_file() {
  src=$1
  target=$2
  mode=$3

  target_dir=$(dirname "$target")
  target_base=$(basename "$target")
  tmp="$target_dir/.$target_base.tmp.$$"

  mkdir -p "$target_dir"
  rm -f "$tmp"
  cp "$src" "$tmp"
  chmod "$mode" "$tmp"
  mv -f "$tmp" "$target"
}

write_atomic_text_file() {
  target=$1
  mode=$2

  target_dir=$(dirname "$target")
  target_base=$(basename "$target")
  tmp="$target_dir/.$target_base.tmp.$$"

  mkdir -p "$target_dir"
  rm -f "$tmp"
  cat >"$tmp"
  chmod "$mode" "$tmp"
  mv -f "$tmp" "$target"
}

atomic_symlink() {
  src=$1
  target=$2

  target_dir=$(dirname "$target")
  target_base=$(basename "$target")
  tmp="$target_dir/.$target_base.link.$$"

  mkdir -p "$target_dir"
  rm -f "$tmp"
  ln -s "$src" "$tmp"
  mv -f "$tmp" "$target"
}

expand_path_template() {
  # Trusted local generated templates only.
  eval "printf '%s\n' \"$1\""
}

install_pkg() {
  pkg=$1

  if [ "$(id -u)" -eq 0 ]; then
    pm_prefix=""
  elif command -v sudo >/dev/null 2>&1; then
    pm_prefix="sudo"
  else
    return 127
  fi

  if command -v apt-get >/dev/null 2>&1; then
    [ "${DOMAIN_DRY_RUN:-${DRY_RUN:-0}}" -eq 1 ] && { printf 'would install pkg: %s via apt-get\n' "$pkg"; return 0; }
    $pm_prefix apt-get update
    $pm_prefix env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg"
    return 0
  fi

  if command -v pacman >/dev/null 2>&1; then
    [ "${DOMAIN_DRY_RUN:-${DRY_RUN:-0}}" -eq 1 ] && { printf 'would install pkg: %s via pacman\n' "$pkg"; return 0; }
    $pm_prefix pacman -Sy --noconfirm --needed "$pkg"
    return 0
  fi

  return 127
}
