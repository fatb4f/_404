#!/usr/bin/env sh
# interactive zsh user config hook.
# shellcheck shell=sh

zsh_dir="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

[ -r "$zsh_dir/aliases.zsh" ] && . "$zsh_dir/aliases.zsh"

br() {
  local cmd cmd_file code
  cmd_file=$(mktemp)
  if broot --outcmd "$cmd_file" "$@"; then
    cmd=$(<"$cmd_file")
    command rm -f "$cmd_file"
    eval "$cmd"
  else
    code=$?
    command rm -f "$cmd_file"
    return "$code"
  fi
}

fzf.nameddirs() {
  local mode="${1:-cd}"
  local path
  local fzf_bin="${commands[fzf]:-$HOME/.local/bin/fzf}"

  if [[ ! -x "$fzf_bin" ]]; then
    print -u2 'fzf.nameddirs: fzf not found'
    return 127
  fi

  path="$(
    print -rl -- "${(@k)nameddirs}" |
      "$fzf_bin" --prompt='dir > '
  )" || return

  path="${nameddirs[$path]}"

  case "$mode" in
    cd) cd "$path" ;;
    br) br "$path" ;;
    *)  return 1 ;;
  esac
}

y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
