legacy_home="/home/_404"

unset_legacy_var() {
  local name="$1"
  local value

  eval "value=\${$name-}"
  case "$value" in
    "$legacy_home"|"$legacy_home"/*)
      unset "$name"
      ;;
  esac
}

strip_legacy_path() {
  local segment
  local new_path=""
  local old_ifs="$IFS"

  IFS=:
  for segment in ${PATH-}; do
    case "$segment" in
      ""|"${legacy_home}"|"${legacy_home}"/*)
        continue
        ;;
    esac
    new_path="${new_path:+$new_path:}$segment"
  done
  IFS="$old_ifs"

  PATH="$new_path"
  export PATH
}

for var in \
  XDG_CACHE_HOME \
  XDG_CONFIG_HOME \
  XDG_DATA_HOME \
  XDG_DATA_BIN \
  XDG_STATE_HOME \
  XDG_CONFIG_DIRS \
  XDG_DATA_DIRS \
  ANDROID_USER_HOME \
  LESSHISTFILE \
  ZSH_CACHE_DIR \
  PIP_CACHE_DIR \
  PYTHONPYCACHEPREFIX \
  PYTEST_ADDOPTS \
  RUFF_CACHE_DIR \
  UV_CACHE_DIR \
  CARGO_HOME \
  RUSTUP_HOME \
  HISTFILE \
  EDITOR \
  VISUAL \
  GNUPGHOME \
  PASSWORD_STORE_DIR \
  PRJROOT \
  CODEX_HOME \
  CODEX_STATE \
  KITTY_CACHE_DIRECTORY \
  DIR_BOOTSTRAP
do
  unset_legacy_var "$var"
done

strip_legacy_path

xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
xdg_config_home="${xdg_config_home%/}"
env_dir="$xdg_config_home/shell/env.d"
for f in "$env_dir"/*.sh; do
  [ -r "$f" ] || continue
  . "$f"
done

unset env_dir f xdg_config_home
