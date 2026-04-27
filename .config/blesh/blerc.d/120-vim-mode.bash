# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Settings for Vim mode

function blerc/vim-load-hook {
  ((_ble_bash >= 40300)) && builtin bind 'set keyseq-timeout 1'

  #----------------------------------------------------------------------------
  # Mode indicator / mode naming

  ## The following option specifies the content of the mode indicator shown in
  ## the info line as a prompt sequence.

  #bleopt prompt_vi_mode_indicator='\q{keymap:vi/mode-indicator}'

  ## The following option controls whether the prompt sequence
  ## \q{keymap:vi/mode-indicator} is activated. When this option has a
  ## non-empty value, \q{keymap:vi/mode-indicator} is expanded to the mode
  ## indicator. Otherwise, \q{keymap:vi/mode-indicator} is expanded to the
  ## empty string.

  bleopt keymap_vi_mode_show=1

  ## The following options specify the name of modes in
  ## \q{keymap:vi/mode-indicator}.

  bleopt keymap_vi_mode_name_insert=INSERT
  #bleopt keymap_vi_mode_name_replace=REPLACE
  #bleopt keymap_vi_mode_name_vreplace=VREPLACE
  bleopt keymap_vi_mode_name_visual=VISUAL
  bleopt keymap_vi_mode_name_select=SELECT
  #bleopt keymap_vi_mode_name_linewise=LINE
  #bleopt keymap_vi_mode_name_blockwise=BLOCK

  ## This option specifies the result of \q{keymap:vi/mode-indicator} in the
  ## normal mode. For example, if you want to show an explicit name of the
  ## normal mode like in other modes, please use the following setting:

  bleopt keymap_vi_mode_string_nmap:=$'\e[1m-- NORMAL --\e[m'

  ## This option specifies that all the prompts should be recalculated on the
  ## mode change. When this option has a non-empty value, the prompt will be
  ## recalculated.

  bleopt keymap_vi_mode_update_prompt=1

  ble-bind -m vi_imap -f 'C-x C-e' edit-and-execute-command
  ble-bind -m vi_nmap -f 'C-x C-e' edit-and-execute-command

  ble-bind -m vi_imap -f C-up history-prev
  ble-bind -m vi_imap -f C-down history-next
  ble-bind -m vi_nmap -f C-up 'vi-command/history-prev'
  ble-bind -m vi_nmap -f C-down 'vi-command/history-next'

  #----------------------------------------------------------------------------
  # Insert-mode input / line entry

  ## The following setting sets up the keymap settings with Meta modifiers.
  ## With this setting, M-RET can be used to insert a newline in the
  ## commandline.

  ble-decode/keymap:vi_imap/define-meta-bindings

  ## The default mapping of <M-backspace> (whose actual key sequence depends on
  ## your terminal) copies the previous shell word in the kill ring. Instead,
  ## the following settings will kill the backward word as in the default
  ## readline.

  #ble-bind -m vi_imap -f 'M-C-?' kill-backward-cword
  #ble-bind -m vi_imap -f 'M-DEL' kill-backward-cword
  #ble-bind -m vi_imap -f 'M-C-h' kill-backward-cword
  #ble-bind -m vi_imap -f 'M-BS'  kill-backward-cword

  ## The default mapping of C-k is kill-forward-line. If you want to input
  ## digraphs with <C-k>{char1}{char2}, use the following setting:

  #ble-bind -m vi_imap -f 'C-k' 'vi_imap/insert-digraph'

  #----------------------------------------------------------------------------
  # Command submission / cancel / discard

  ## C-RET can be optionally configured so that it forcibly executes the
  ## command.

  #ble-bind -m vi_imap -f 'C-RET' accept-line

  ## The default mapping of RET and C-m in insert mode inserts newline with
  ## multiline commands or incomplete commands. They move the cursor position to
  ## the next line in normal mode. Instead, with the following setting, RET and
  ## C-m always cause execution of the command even in multiline mode or when
  ## the command is not syntactically completed.

  #ble-bind -m vi_imap -f 'C-m' accept-line
  #ble-bind -m vi_imap -f 'RET' accept-line
  #ble-bind -m vi_nmap -f 'C-m' accept-line
  #ble-bind -m vi_nmap -f 'RET' accept-line

  ## The default mapping of C-o is vi_imap/single-command-mode. If you want to
  ## execute the current command line and load the next history entry with
  ## <C-o>, use the following setting:

  #ble-bind -m vi_imap -f 'C-o' accept-and-next

  ## The default mapping of C-c is vi_imap/normal-mode-without-insert-leave
  ## (imap), vi-command/cancel (nmap). If you instead want to discard the
  ## current line and go to the next line, you can bind C-c to discard-line:

  #ble-bind -m vi_imap -f 'C-c' discard-line
  #ble-bind -m vi_nmap -f 'C-c' discard-line

  #----------------------------------------------------------------------------
  # Line-local navigation / multiline entry movement

  ## The default mapping of 'g g' and G moves the current position in the
  ## command history. If you would like to move the cursor position in the
  ## current command entry, you can overwrite the bindings as follows.

  ble-bind -m vi_nmap -f 'g g' vi-command/first-nol
  ble-bind -m vi_omap -f 'g g' vi-command/first-nol
  ble-bind -m vi_xmap -f 'g g' vi-command/first-nol
  ble-bind -m vi_nmap -f 'G' vi-command/last-line
  ble-bind -m vi_omap -f 'G' vi-command/last-line
  ble-bind -m vi_xmap -f 'G' vi-command/last-line

  ## The default mapping of C-r in the normal mode is vi_nmap/redo. If you want
  ## to use incremental search mode from Emacs in the Vim mode (as in Readline),
  ## please use the following keybinding.

  #ble-bind -m vi_nmap -f 'C-r' history-isearch-backward

  #----------------------------------------------------------------------------
  # Cursor shapes / terminal mode hooks

  ## Cursor settings

  ble-bind -m vi_nmap --cursor 2
  ble-bind -m vi_imap --cursor 5
  ble-bind -m vi_omap --cursor 4
  ble-bind -m vi_xmap --cursor 2
  ble-bind -m vi_smap --cursor 2
  ble-bind -m vi_cmap --cursor 0

  ## DECSCUSR setting
  ##
  ##   If you don't have the entry Ss in terminfo, yet your terminal supports
  ##   DECSCUSR, please comment out the following line to enable DECSCUSR.
  ##
  #_ble_term_Ss=$'\e[@1 q'

  ## Control sequences that will be output on entering each mode
  #bleopt term_vi_nmap=
  #bleopt term_vi_imap=
  #bleopt term_vi_omap=
  #bleopt term_vi_xmap=
  #bleopt term_vi_smap=
  #bleopt term_vi_cmap=

  #----------------------------------------------------------------------------
  # Miscellaneous vi-mode settings

  ## This option controls the frequency of recording "undo". When the value
  ## "more" is specified, "undo" will be recorded for various operations in
  ## vi_imap.

  #bleopt keymap_vi_imap_undo=

  ## This option controls the behavior of motion in select mode. The value is a
  ## list of words separated by commas. When the word "stopsel" is contained in
  ## this option, ble.sh exits the select mode with a motion in select mode.

  #bleopt keymap_vi_keymodel=

  ## This option sets the upper limit of the maximal depth of recurrence of
  ## replaying keyboard macros.

  #bleopt keymap_vi_macro_depth=64

  ## This option specifies the operator name when the user inputs g@ in normal
  ## mode. The function "ble/keymap:vi/operator:$value", where "$value" is the
  ## value of this setting, is used as the implementation of the operator.

  #bleopt keymap_vi_operatorfunc=

  ## When this option has a non-empty value, "/", "?", "n", "N" search the
  ## word on the current position. When this option has the empty value, these
  ## keys follow the behavior of vim.

  #bleopt keymap_vi_search_match_current=

  #----------------------------------------------------------------------------
  # Plugins

  ## vim-surround

  #ble-import vim-surround
  #bleopt vim_surround_45:=$'$( \r )'
  #bleopt vim_surround_61:=$'$(( \r ))'

  ## vim-arpeggio

  #ble-import vim-arpeggio
  #bleopt vim_arpeggio_timeoutlen=10
  #ble/lib/vim-arpeggio.sh/bind -s jk 'hello'

  ## vim-airline

  #ble-import vim-airline
  #bleopt vim_airline_theme=light
  #bleopt vim_airline_section_a='\e[1m\q{lib/vim-airline/mode}'
  #bleopt vim_airline_section_b='\q{lib/vim-airline/gitstatus}'
  #bleopt vim_airline_section_c='\w'
  #bleopt vim_airline_section_x='bash'
  #bleopt vim_airline_section_y='$_ble_util_locale_encoding[unix]'
  #bleopt vim_airline_section_z=' \q{history-percentile} \e[1m!\q{history-index}/\!\e[22m \q{position}'
  #bleopt vim_airline_left_sep=$'\uE0B0'
  #bleopt vim_airline_left_alt_sep=$'\uE0B1'
  #bleopt vim_airline_right_sep=$'\uE0B2'
  #bleopt vim_airline_right_alt_sep=$'\uE0B3'
  #bleopt vim_airline_symbol_branch=$'\uE0A0'
  #bleopt vim_airline_symbol_dirty=$'\u26A1'
}
blehook/eval-after-load keymap_vi blerc/vim-load-hook
