HISTSIZE=50000
SAVEHIST=50000

# history policy
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_BY_COPY
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# navigation-heavy workstation
setopt AUTO_CD
setopt AUTO_PUSHD
setopt CDABLE_VARS
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT
setopt CD_SILENT

# correction-friendly helper shell
setopt CORRECT

# SHARE_HISTORY should not be combined with the incremental append variants
unsetopt INC_APPEND_HISTORY
unsetopt INC_APPEND_HISTORY_TIME

# Keep correction scoped to command names only
unsetopt CORRECT_ALL

# kitty integration for direct and nested zsh shells
if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
  export KITTY_SHELL_INTEGRATION="enabled no-cursor"
  autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
  kitty-integration
  unfunction kitty-integration
fi

# prompt/completion tuning
zstyle ':zim:prompt-pwd' git-root yes
zstyle ':zim:completion' dumpfile "${ZSH_CACHE_DIR}/.zcompdump"
zstyle ':completion::complete:*' cache-path "${ZSH_CACHE_DIR}/zcompcache"

# vi-mode + history profile
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_READKEY_ENGINE=$ZVM_READKEY_ENGINE_NEX
ZVM_KEYTIMEOUT=0.4
ZVM_ESCAPE_KEYTIMEOUT=0.03
ZVM_CURSOR_STYLE_ENABLED=true
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_OPPEND_MODE_CURSOR=$ZVM_CURSOR_UNDERLINE
ZVM_VI_EDITOR=${EDITOR:-nvim}

HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

function zvm_after_init() {
  local up="${terminfo[kcuu1]:-$'\e[A'}"
  local down="${terminfo[kcud1]:-$'\e[B'}"

  bindkey -M viins "$up" history-beginning-search-backward-end
  bindkey -M viins "$down" history-beginning-search-forward-end
  bindkey -M viins '^P' history-beginning-search-backward-end
  bindkey -M viins '^N' history-beginning-search-forward-end

  bindkey -M viins '^R' history-incremental-search-backward
  bindkey -M vicmd '^R' history-incremental-search-backward
}

function zvm_after_lazy_keybindings() {
  local up="${terminfo[kcuu1]:-$'\e[A'}"
  local down="${terminfo[kcud1]:-$'\e[B'}"

  zvm_bindkey vicmd 'k' history-substring-search-up
  zvm_bindkey vicmd 'j' history-substring-search-down
  zvm_bindkey vicmd "$up" history-substring-search-up
  zvm_bindkey vicmd "$down" history-substring-search-down
}

# zim bootstrap
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o "${ZIM_HOME}/zimfw.zsh" \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

if [[ ! -e "${ZIM_HOME}/init.zsh" || "${ZIM_HOME}/init.zsh" -ot "${ZIM_CONFIG_FILE}" ]]; then
  source "${ZIM_HOME}/zimfw.zsh" install
fi

if [[ -r "${ZIM_HOME}/init.zsh" ]]; then
  source "${ZIM_HOME}/init.zsh"
fi

if (( SHLVL > 1 )); then
  RPROMPT="(${SHLVL}) ${RPROMPT}"
fi

if [[ -d "${ZDOTDIR}/fn" ]]; then
  typeset -a zsh_fn_names
  zsh_fn_names=("${(@f)$(printf '%s\n' "${ZDOTDIR}/fn"/*(N:t))}")
  if (( ${#zsh_fn_names} )); then
    autoload -Uz "${zsh_fn_names[@]}"
  fi
fi

if [[ -r "${ZDOTDIR}/aliases.zsh" ]]; then
  source "${ZDOTDIR}/aliases.zsh"
fi

if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh 2>/dev/null | sed '/^compdef /d')" || true
  typeset -gA _comps
  _comps[gh]=_gh
fi

if command -v yadm >/dev/null 2>&1; then
  alias dots=yadm
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh 2>/dev/null)" || true
  function __zoxide_hook() {
    local zoxide_bin="${commands[zoxide]:-$HOME/.local/bin/zoxide}"

    [[ -x "$zoxide_bin" ]] || return 0
    "$zoxide_bin" add -- "$(__zoxide_pwd)"
  }
fi
