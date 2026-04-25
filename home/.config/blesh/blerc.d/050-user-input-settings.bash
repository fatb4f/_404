# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## User input settings

## The following setting sets the default keymap. The value "emacs" specifies
## that the emacs keymap should be used. The value "vi" specifies that the vi
## keymap (insert mode) should be used as the default. The value "auto"
## specifies that the keymap should be automatically selected from "emacs" or
## "vi" according to the current readline state "set -o emacs" or "set -o vi".

bleopt default_keymap=vi


## The following setting controls the treatment of isolated ESCs.  The value
## "esc" indicates that it should be treated as ESC.  The value "meta"
## indicates that it should be treated as Meta modifier.  The value "auto"
## indicates that the behavior will be switched to an appropriate side of "esc"
## or "meta" depending on the current keymap.

bleopt decode_isolated_esc=esc


## The following setting specifies the byte code used to abort the currently
## processed inputs. The default value 28 corresponds to "C-\".

#bleopt decode_abort_char=28


## The following settings sets up the behavior for errors while user input
## decoding. "error_char" is the decoding error for the current character
## encoding. "error_cseq" indicates the unrecognized CSI sequences.
## "error_kseq" indicates the unbound key sequences. "abell" and "vbell" turn
## on/off the audible bells and visible bells on errors. If the variable is
## empty the bells are turned off, or otherwise turned on. "discard" controls
## if the chars/sequences will be discarded or processed in later stage. If a
## non-empty value is given, chars/sequences are discarded.

#bleopt decode_error_char_abell=
bleopt decode_error_char_vbell=1
#bleopt decode_error_char_discard=
#bleopt decode_error_cseq_abell=
bleopt decode_error_cseq_vbell=1
#bleopt decode_error_cseq_discard=1
#bleopt decode_error_kseq_abell=1
bleopt decode_error_kseq_vbell=1
#bleopt decode_error_kseq_discard=1


## This variable sets the limit to the count of recursive calls of keyboard
## macros.

#bleopt decode_macro_limit=1024


## When a non-empty value is specified to this settings, the terminal's
## Bracketed Paste Mode (DEC mode 2004) is enabled.  This setting is
## synchronized with the readline variable "enable-bracketed-paste".

bleopt term_bracketed_paste_mode=on

