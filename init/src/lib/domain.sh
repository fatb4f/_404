#!/usr/bin/env sh
set -eu


read_specs() {
  # $1: multi-line spec string
  printf '%s\n' "$1" | sed '/^[[:space:]]*$/d'
}

domain_load_env() {
  domain_dir=$1
  # shellcheck disable=SC1090
  . "$domain_dir/domain.env.sh"

  : "${DOTS_HOME:=$(root_dots_home)}"
  : "${XDG_CONFIG_HOME:=$(xdg_config_home)}"
  : "${XDG_DATA_HOME:=$(xdg_data_home)}"
  : "${XDG_OPT_HOME:=$(xdg_opt_home)}"
  : "${XDG_STATE_HOME:=$(xdg_state_home)}"
  : "${XDG_CACHE_HOME:=$(xdg_cache_home)}"
  : "${TOOL_PATH_HOME:=$(tool_path_home)}"
  : "${TOOL_PREFIX_HOME:=$(tool_prefix_home)}"

  export DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME
  export DOMAIN_PREFIX DOMAIN_STATE DOMAIN_CACHE DOMAIN_BIN_HOME DOMAIN_SHARE_HOME
}

domain_install_files() {
  read_specs "${DOMAIN_FILES:-}" | while IFS='|' read -r src_t dst_t mode; do
    src="$DOMAIN_DIR/$src_t"
    dst=$(expand_path_template "$dst_t")
    case "$dst" in
      "$DOMAIN_PREFIX"/*|"${DOMAIN_PREFIX}")
        continue
        ;;
    esac
    printf 'activate %-22s %s -> %s\n' "$DOMAIN_STAGE" "${src#$ROOT/}" "$dst"
    [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ] && continue
    atomic_copy_file "$src" "$dst" "$mode"
  done
}

domain_install_copies() {
  read_specs "${DOMAIN_COPIES:-}" | while IFS='|' read -r src_t dst_t mode; do
    src="$DOMAIN_DIR/$src_t"
    dst=$(expand_path_template "$dst_t")
    printf 'activate %-22s %s -> %s\n' "$DOMAIN_STAGE" "${src#$ROOT/}" "$dst"
    [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ] && continue
    atomic_copy_file "$src" "$dst" "$mode"
  done
}

domain_install_links() {
  read_specs "${DOMAIN_LINKS:-}" | while IFS='|' read -r src_t dst_t; do
    src=$(expand_path_template "$src_t")
    dst=$(expand_path_template "$dst_t")
    printf 'activate %-22s %s -> %s\n' "$DOMAIN_STAGE" "$src" "$dst"
    [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ] && continue
    atomic_symlink "$src" "$dst"
  done
}

domain_install_from_generated() {
  ROOT=$1
  DOMAIN_DIR=$2
  export ROOT DOMAIN_DIR

  domain_load_env "$DOMAIN_DIR"

  if [ "${DOMAIN_DRY_RUN:-0}" -ne 1 ]; then
    mkdir -p "$DOMAIN_STATE" "$DOMAIN_CACHE" "$TOOL_PATH_HOME" "$TOOL_PREFIX_HOME"
  fi

  if [ -n "${DOMAIN_REQUIRES_READY:-}" ]; then
    for stage in $DOMAIN_REQUIRES_READY; do
      stage_require_ready "$stage"
    done
  fi

  provider_install_payload
  domain_install_copies
  domain_install_links
  stage_mark_ready "$DOMAIN_STAGE"
}

domain_check_command() {
  id=$1
  command_text=$2
  severity=$3

  if eval "$command_text"; then
    emit_check "$DOMAIN_ID" "$id" true ok "$command_text"
  else
    emit_check "$DOMAIN_ID" "$id" false "$severity" "$command_text"
    [ "$severity" = fatal ] && return 1
    return 0
  fi
}

domain_check_from_generated() {
  ROOT=$1
  DOMAIN_DIR=$2
  export ROOT DOMAIN_DIR

  domain_load_env "$DOMAIN_DIR"

  status=0
  read_specs "${DOMAIN_CHECKS:-}" | while IFS='|' read -r id command_text severity; do
    if ! domain_check_command "$id" "$command_text" "$severity"; then
      exit 1
    fi
  done || status=1

  return "$status"
}
