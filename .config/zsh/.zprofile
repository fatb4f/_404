if [[ -r /etc/profile ]]; then
  source /etc/profile
fi

xdg_config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
xdg_config_home="${xdg_config_home%/}"
source "$xdg_config_home/shell/load-env.sh"
unset xdg_config_home
