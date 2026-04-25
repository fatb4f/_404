source "$HOME/.config/shell/load-env.sh"

export ZIM_HOME="${XDG_CACHE_HOME:-$HOME/.cache}/zim"
export ZIM_CONFIG_FILE="$ZDOTDIR/zimrc"
export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export SHELL="${XDG_DATA_BIN}/zsh"

mkdir -p "${XDG_STATE_HOME}/zsh"

fpath=("$ZDOTDIR/fn" $fpath)
