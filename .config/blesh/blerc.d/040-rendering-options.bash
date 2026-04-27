# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Rendering options


## "tab_width" specifies the width of TAB on the command line. When an empty
## value is specified, the width in terminfo (tput it) is used.

#bleopt tab_width=


## "char_width_mode" specifies the width of East_Asian_Width=A characters.
## When the value "east" is specified, the width is 2. When the value "west" is
## specified, the width is 1.  When the value "emacs" is specified, the width
## table (depending on characters) used in Emacs is used.  When the value
## "musl" is specified, the table for "wcwidth" of the musl C library in 2014
## is used [Note: recent versions of musl library is more conforming to Unicode
## so favor "west" or "east"].  When "auto" is specified, the character width
## mode is automatically selected based on interactions with the terminal.

#bleopt char_width_mode=auto


## "char_width_version" specifies the Unicode version that char width
## determination bases on.  When "auto" is specified, ble.sh automatically
## tests the behavior of the terminal on startup and try to determine the
## appropriate version.  Supported versions are "4.1", "5.0", "5.2", "6.0",
## "6.1", "6.2", "6.3", "7.0", "8.0", "9.0", "10.0", "11.0", "12.0", "12.1",
## "13.0", "14.0", "15.0", and "15.1".  The default value is "auto".

#bleopt char_width_version=auto


## "emoji_width" specifies the width of emoji characters.  If an empty value is
## specified, special treatment of emoji is disabled.

#bleopt emoji_width=2


## "emoji_version" specifies the version of Unicode Emoji.  Available values
## are 0.6, 0.7, 1.0, 2.0, 3.0, 4.0, 5.0, 11.0, 12.0, 12.1, 13.0, 13.1, 14.0,
## 15.0, and 15.1.

#bleopt emoji_version=13.1


## "emoji_opts" is a colon-separated list that represents the terminal
## capability for emojis.  When "tpvs" and "epvs" are specified, TPVS and EPVS
## (text/emoji presentation variation selectors), respectively, can be used to
## change he representation of emoji characters.  When "zwj" is specified, the
## emoji ZWJ sequences are supported.  When "ri" is specified, the flag emojis
## formed by two Regional_Indicators are supported.  When "unqualified" is
## specified, unqualified emojis are treated as emojis as well as the qualified
## emojis.

#bleopt emoji_opts=ri


## This option specifies the type of the supported grapheme cluster of the
## terminal.  The empty string indicates that the terminal does not support the
## grapheme clusters.  The values "extended" and "legacy" indicate that the
## terminal supports the extended and legacy grapheme clusters, respectively.

#bleopt grapheme_cluster=extended


## This option controls the behavior when ble.sh receives SIGWINCH.
## * When the value "redraw-safe" is specified, ble.sh redraws the new prompt
##   starting from the line of the current cursor position.
## * When the value "redraw-prev" is specified, ble.sh tries to go to the
##   beginning of the current prompt and overwrite the current one.  This is
##   similar to the behavior of GNU Readline.  This possibly erase the output
##   of the previous command because ble.sh tries to go to the beginning of the
##   current prompt assuming that the number of lines in the prompt does not
##   change by the terminal resizing.
## * When the value "redraw-here" is specified, ble.sh tries to determine the
##   number of lines that can be safely erased and go to the beginning of the
##   safe lines before the redraw.  This is the default behavior.  In
##   principle, this can also erase the previous outputs, but it would be
##   supposed to be rarely happen as far as the text reflowing of the terminal
##   behaves in a reasonable way.
## * When the value "clear" is specified, the terminal content is erased and
##   the new prompt will be drawn at the top of the terminal.  The previous
##   terminal contents including the command outputs will be lost.

#bleopt canvas_winch_action=redraw-here

