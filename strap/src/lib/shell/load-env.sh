if [ -n "${SHELL_ENV_LOADED-}" ]; then
  return 0
fi

SHELL_ENV_LOADED=1

env_dir="${XDG_CONFIG_HOME:-$HOME/.config}/shell/env.d"
for f in "$env_dir"/*.sh; do
  [ -r "$f" ] || continue
  . "$f"
done

unset env_dir f
