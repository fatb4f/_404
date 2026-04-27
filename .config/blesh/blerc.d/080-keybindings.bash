# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Keybindings


## The default mapping of <SP> in ble.sh is magic-space which performs history
## and sabbrev expansion before inserting a space.  If you want to insert just
## a space without expansions as Bash's default, use the following setting:

#ble-bind -f 'SP' 'self-insert'


## The default mapping of `/' (<slash>) in ble.sh is magic-slash which performs
## sabbrev expansions of the name ` ~*'.  If you want to insert just a slash
## without expansions as Bash's default, use the following setting:

#ble-bind -f '/' 'self-insert'


## If you want to search the already input string using <up> and <down> keys,
## use the following setting:

#ble-bind -f up 'history-search-backward'
#ble-bind -f down 'history-search-forward'


## If you want to immediately run the matched command by RET, you can specify
## the option "immediate-accept" to nsearch widgets:

#ble-bind -f up 'history-search-backward immediate-accept'
#ble-bind -f down 'history-search-forward immediate-accept'


## If you want to kill/copy words including the spaces preceding them, you can
## use the following keybindings:

#ble-bind -f C-w 'kill-region-or kill-uword'
#ble-bind -f M-w 'copy-region-or copy-uword'


## The following keybindings can be used to execute the command by RET even in
## the multiline mode.

# # For emacs editing mode
# ble-bind -m emacs -f 'C-m' 'accept-line'
# ble-bind -m emacs -f 'RET' 'accept-line'

# # For vim editing mode
# ble-bind -m vi_imap -f 'C-m' 'accept-line'
# ble-bind -m vi_imap -f 'RET' 'accept-line'
# ble-bind -m vi_nmap -f 'C-m' 'accept-line'
# ble-bind -m vi_nmap -f 'RET' 'accept-line'


## If you want to accept the suggestion by auto-complete using TAB, please use
## the following keybindings.  By default, <right> key can be used to accept
## the suggestion, and <TAB> is assigned to the normal TAB completion which is
## independent of auto-complete.

# ble-bind -m auto_complete -f C-i auto_complete/insert
# ble-bind -m auto_complete -f TAB auto_complete/insert

