# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Terminal state control


## When the follwoing setting is set to a non-empty value, ble.sh saves the TTY
## state at the end of the command executation and restores it before the next
## command execution.  This adds a slight overload of running an extra call of
## stty.  If this is enabled, when a command breaks the TTY state, the effect
## remains in later commands.

#bleopt term_stty_restore=1


## The following setting specifies the cursor type when commands are executed.
## The cursor type is specified by the argument of the control function
## DECSCUSR.

#bleopt term_cursor_external=0


## The following settings, external and internal, specify the "modifyOtherKeys"
## states [the control function SM(>4)] when commands are executed and when
## ble.sh has control, respectively.

#bleopt term_modifyOtherKeys_external=auto
#bleopt term_modifyOtherKeys_internal=auto


## The following setting controls whether the kitty-keyboard-protocol sequences
## should pass-through the terminal multiplexers when the outermost terminal is
## kitty.  When this option has a non-empty string, the pass-through kitty
## protocol sequences are enabled.
##
## * This is intended to be used with tmux-3.4+.  This works with tmux-3.3a and
##   below as far as the user does not enable CapsLock or NumLock.  Note that
##   this might cause problems of keyboard inputs after detaching from tmux;
##   You might lose the control of the terminal applications that do not
##   support extended keys outside the terminal multiplexers.
##
## * This will cause the same problems when used with multiple windows in GNU
##   screen.  You will lose the control of the terminal applications without
##   the support for extended keys when there are more than one ble.sh session
##   or when there is at least one foreground ble.sh session in GNU screen.

#bleopt term_modifyOtherKeys_passthrough_kitty_protocol=1

