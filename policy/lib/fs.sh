#!/usr/bin/env sh
set -eu

xdg_config_home() { printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"; }
xdg_data_home() { printf '%s\n' "${XDG_DATA_HOME:-$HOME/.local/share}"; }
xdg_state_home() { printf '%s\n' "${XDG_STATE_HOME:-$HOME/.local/state}"; }
xdg_cache_home() { printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}"; }

state_dir() { printf '%s/_404\n' "$(xdg_state_home)"; }
data_dir() { printf '%s/_404\n' "$(xdg_data_home)"; }
releases_dir() { printf '%s/releases\n' "$(data_dir)"; }
current_root() { printf '%s/current\n' "$(data_dir)"; }
release_root() { printf '%s/releases/%s\n' "$(data_dir)" "${1:?activation id required}"; }
bootstrap_state_dir() { printf '%s/bootstrap\n' "$(state_dir)"; }
stage_ready_path() { printf '%s/%s.ready\n' "$(bootstrap_state_dir)" "${1:?stage required}"; }

stage_require_ready() {
  marker=$(stage_ready_path "$1")
  [ -f "$marker" ] || {
    if [ "${DRY_RUN:-0}" -eq 1 ]; then
      printf '[dry-run] would require stage ready marker: %s\n' "$marker"
      return 0
    fi
    printf >&2 'missing stage ready marker: %s\n' "$marker"
    return 1
  }
}

stage_mark_ready() {
  marker=$(stage_ready_path "$1")
  if [ "${DRY_RUN:-0}" -eq 1 ]; then
    printf '[dry-run] would mark stage ready: %s\n' "$marker"
    return 0
  fi
  mkdir -p "$(dirname "$marker")"
  : > "$marker"
}

resolve_target() {
  case "$1" in
    home:*) printf '%s/%s\n' "$HOME" "${1#home:}" ;;
    xdg_config:*) printf '%s/%s\n' "$(xdg_config_home)" "${1#xdg_config:}" ;;
    xdg_state:*) printf '%s/%s\n' "$(xdg_state_home)" "${1#xdg_state:}" ;;
    *) printf >&2 'unknown target prefix: %s\n' "$1"; return 64 ;;
  esac
}

backup_path_for() {
  backup_root=$1
  target=$2
  # Preserve enough path shape while staying under backup_root.
  rel=$(printf '%s' "$target" | sed 's#^/##; s#[^A-Za-z0-9._/-]#_#g')
  printf '%s/%s\n' "$backup_root" "$rel"
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

source_optional() {
  root=$1
  rel=$2

  path=$(require_file "$root" "$rel") || return 0
  . "$path"
}

source_required() {
  root=$1
  rel=$2

  path=$(require_file "$root" "$rel") || return 1
  . "$path"
}

atomic_copy_file() {
  src=$1
  target=$2
  mode=$3

  ac_target_dir=$(dirname "$target")
  ac_target_base=$(basename "$target")
  tmp="$ac_target_dir/.$ac_target_base.tmp.$$"

  mkdir -p "$ac_target_dir"
  rm -f "$tmp"

  cp "$src" "$tmp"
  chmod "$mode" "$tmp"
  mv -f "$tmp" "$target"
}

write_atomic_text_file() {
  target=$1
  mode=$2

  wt_target_dir=$(dirname "$target")
  wt_target_base=$(basename "$target")
  tmp="$wt_target_dir/.$wt_target_base.tmp.$$"

  mkdir -p "$wt_target_dir"
  rm -f "$tmp"
  cat >"$tmp"
  chmod "$mode" "$tmp"
  mv -f "$tmp" "$target"
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
    [ "${DRY_RUN:-0}" -eq 1 ] && {
      printf 'would install pkg: %s via apt-get\n' "$pkg"
      return 0
    }
    $pm_prefix apt-get update
    $pm_prefix env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$pkg"
    return 0
  fi

  if command -v pacman >/dev/null 2>&1; then
    [ "${DRY_RUN:-0}" -eq 1 ] && {
      printf 'would install pkg: %s via pacman\n' "$pkg"
      return 0
    }
    $pm_prefix pacman -Sy --noconfirm --needed "$pkg"
    return 0
  fi

  if command -v dnf >/dev/null 2>&1; then
    [ "${DRY_RUN:-0}" -eq 1 ] && {
      printf 'would install pkg: %s via dnf\n' "$pkg"
      return 0
    }
    $pm_prefix dnf install -y "$pkg"
    return 0
  fi

  if command -v apk >/dev/null 2>&1; then
    [ "${DRY_RUN:-0}" -eq 1 ] && {
      printf 'would install pkg: %s via apk\n' "$pkg"
      return 0
    }
    $pm_prefix apk add "$pkg"
    return 0
  fi

  return 127
}
