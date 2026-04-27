export ZDOTDIR="${ZDOTDIR:-$HOME/.config/zsh}"

if [[ -r "$ZDOTDIR/.zprofile" ]]; then
  source "$ZDOTDIR/.zprofile"
fi
