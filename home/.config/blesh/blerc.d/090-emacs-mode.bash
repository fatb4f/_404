# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Settings for Emacs mode

function blerc/emacs-load-hook {
  #----------------------------------------------------------------------------
  # Settings for the mode indicator

  ## The following option specifies the content of the mode indicator shown in
  ## the info line as a prompt sequence.

  #bleopt prompt_emacs_mode_indicator='\q{keymap:emacs/mode-indicator}'


  ## The following option specifies the multiline mode name used in the prompt
  ## sequence \q{keymap:emacs/mode-indicator} in the multiline editing mode.

  # default
  #bleopt keymap_emacs_mode_string_multiline=$'\e[1m-- MULTILINE --\e[m'
  # do not show the mode name
  #bleopt keymap_emacs_mode_string_multiline=

  #----------------------------------------------------------------------------
  # Keybindings

  ## The default mapping of RET and C-m inserts newline with multiline commands
  ## or incomplete commands.  With the following setting, RET and C-m always
  ## causes the execution of the command even in the multiline mode or when the
  ## command is not syntactically completed.

  #ble-bind -f 'C-m' accept-line
  #ble-bind -f 'RET' accept-line


  ## With the following settings, M-backspace (whose actual key sequence
  ## depends on your terminal) will kill the backward word as in the default
  ## readline.

  #ble-bind -f 'M-C-?' kill-backward-cword
  #ble-bind -f 'M-DEL' kill-backward-cword
  #ble-bind -f 'M-C-h' kill-backward-cword
  #ble-bind -f 'M-BS'  kill-backward-cword

  return 0
}
blehook/eval-after-load keymap_emacs blerc/emacs-load-hook

