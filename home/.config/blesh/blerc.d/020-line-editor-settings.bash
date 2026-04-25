# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Line editor settings


## This option controls the behavior of the bell in the line editing by
## colon-separated values.  When "abell", "vbell", and "visual" are contained,
## the audible bells, the visible bells, and the visual bells are enabled.  The
## audible bell sends BEL to the terminal.  The visible bell shows the message
## on the terminal display.  The visual bell is the GNU-Screen style bell that
## flashes the terminal display by turning on DECSCNM in a short moment.  Old
## settings "edit_vbell" and "edit_abell" should be updated to use "edit_bell".

#bleopt edit_bell=abell


## The following setting turns on the delayed load of history when an non-empty
## value is set.

#bleopt history_lazyload=1


## The following setting turns on the delete selection mode when an non-empty
## value is set. When the mode is turned on the selection is removed when a
## user inserts a character.

#bleopt delete_selection_mode=1


## The following settings control the indentation. "indent_offset" sets the
## indent width. "indent_tabs" controls if tabs can be used for indentation or
## not. If "indent_tabs" is set to 0, tabs will never be used. Otherwise
## indentation is made with tabs and spaces.

#bleopt indent_offset=4
#bleopt indent_tabs=1


## "undo_point" controls the cursor position after "undo".  When "beg" and
## "end" are specified, the cursor will be moved to the beginning and the end,
## respectively, of the dirty section.  When "first" and "last" are specified,
## the cursor position will be the first and last positions, respectively, for
## which the resulting line content is recorded.  When "near" is specified, it
## behaves like "last" for undo and "first" for redo.  Otherwise, it behaves
## like "beg" for vi command modes and "near" for the other modes.  The default
## is "auto".

#bleopt undo_point=near


## The following setting controls forced layout calculations before graphical
## operations. When a non-empty value is specified, the forced calculations are
## enabled. When an empty string is set, the operations are switched to logical
## ones.

#bleopt edit_forced_textmap=1


## The following option controls the interpretation of lines when going to the
## beginning or the end of the current line.  When the value `logical` is
## specified, the logical line is used, i.e., the beginning and the end of the
## line is determined based on the newline characters in the edited text.  When
## the value `graphical` is specified, the graphical line is used, i.e., the
## beginning and the end of the displayed line in the terminal is used.

#bleopt edit_line_type=graphical


## The following option specifies the set of expansions performed by
## magic-space with a colon-separated list of expansion types. "history",
## "sabbrev", "alias", and "autocd" can be specified.  In addition, a
## user-defined expansion can be defined as a shell function
## "ble/complete/expand:<name>" so that "<name>" can be specified to this
## option.

#bleopt edit_magic_expand=history:sabbrev


## This option configures the detailed behavior of the widget "magic-space"
## with a colon-separated list.  If the field "inline-sabbrev-no-insert" is
## specified, the insertion of "SP" is skipped when the inline sabbrev is
## performed by "magic-space".

#bleopt edit_magic_opts=


## This option specifies the expansions performed on accept-line by a
## colon-separated list.  The expansion is performed in a similar way as Bash's
## history expansion.  When "sabbrev", "alias", "autocd", "history", or
## "<name>" as explained in the description of "bleopt edit_magic_expand" is
## specified, the corresponding expansion is attempted on the command line.
## When "verify" is specified, if sabbrev, alias, or autocd expansions changed
## the command line, the execution of the command line is canceled so the user
## can examine or continue to edit the expanded line.  The history expansion
## can be controlled by "shopt -s histverify" in a similar manner.  When
## "verify-syntax" is specified and any expansions change the command string, a
## syntax check is performed.  The command execution is canceled when the
## command string is not syntactically complete.  When "history-line" is
## specified, the history expansion replaces the command line instead of just
## printing the expansion result.  The default value of this option is empty.

#bleopt edit_magic_accept=sabbrev


## The following option controls the position of the info pane where completion
## menu, mode names, and other information are shown.  When the value "top" is
## specified, the info pane is shown just below the command line.  When the
## value "bottom" is specified, the info pane is shown at the bottom of the
## terminal.  The default is "top".

#bleopt info_display=top


## The following settings controls the prompt after the cursor left the command
## line.  "prompt_ps1_final" contains a prompt string.  "prompt_ps1_transient"
## is a colon-separated list of fields "always", "same-dir" and "trim".  The
## prompt is replaced by "prompt_ps1_final" if it has a non-empty value.
## Otherwise, the prompt is trimmed leaving the last line if
## "prompt_ps1_transient" has a field "trim".  Otherwise, the prompt vanishes
## if "prompt_ps1_transient" has a non-empty value.  When
## "prompt_ps1_transient" contains a field "same-dir", the setting of
## "prompt_ps1_transient" is effective only when the current working directory
## did not change since the last command line.

#bleopt prompt_ps1_final=
bleopt prompt_ps1_transient=trim


## The following settings controls the right prompt. "prompt_rps1" specifies
## the contents of the right prompt in the format of PS1.  When the cursor
## leaves the current command line, the right prompt is replaced by
## "prompt_rps1_final" if it has a non-empty value, or otherwise, the right
## prompt vanishes if "prompt_rps1_transient" is set to a non-empty value,

bleopt prompt_rps1='\q{contrib/elapsed} \q{contrib/git-branch}'
#bleopt prompt_rps1_final=
#bleopt prompt_rps1_transient=''


## The following settings specify the content of terminal titles and status
## lines.  "prompt_xterm_title" specifies the terminal title which can be set
## by "OSC 0 ; ... BEL".  "prompt_screen_title" is effective inside terminal
## multiplexers such as GNU screen and tmux and specifies the window title of
## the terminal multiplexer which can be set by "ESC k ... ST".
## "prompt_term_status" is only effective when terminfo entries "tsl" and "fsl"
## (or termcap entries "ts" and "ds") are available, and specifies the content
## of the status line which can be set by the terminfo entries.  When each
## setting has non-empty value, the content of corresponding title or status
## line is replaced just before PS1 is shown.

#bleopt prompt_xterm_title=
#bleopt prompt_screen_title=
#bleopt prompt_term_status=


## The following settings control the status line.  "prompt_status_line"
## specifies the content of the status line.  If its value is empty, the status
## line is not shown.  "prompt_status_align" controls the position of the
## content in the status line.  The face "prompt_status_line" specifies the
## default graphic style of the status line.

#bleopt prompt_status_line=
#bleopt prompt_status_align=left
#ble-face prompt_status_line='fg=231,bg=240'


## "prompt_eol_mark" specifies the contents of the mark used to indicate the
## command output is not ended with newlines. The value can contain ANSI escape
## sequences.

bleopt prompt_eol_mark=''


## "prompt_ruler" specifies the ruler between the previous command and the
## prompt (like powerlevel10k
## "POWERLEVEL9K_PROMPT_{ADD_NEWLINE,SHOW_RULER,RULER_*}").  When the empty
## value is specified, the ruler is disabled.  This is the default.  When the
## value "empty-line" is specified, an empty line is inserted between the
## command and the prompt.  When the other values are specified, the value is
## interpreted as an ANSI sequences, and the result is repeated to fill a line.

#bleopt prompt_ruler=            # no ruler (default)
#bleopt prompt_ruler=empty-line  # empty line
#bleopt prompt_ruler=$'\e[94m-'  # blue line


## "prompt_command_changes_layout" specifies whether the commands called from
## the blehook PRECMD or the variable PROMPT_COMMAND output texts to the
## terminal and changes the layout.  When a non-empty value is specified,
## ble.sh resets the layout before running the hooks PRECMD and PROMPT_COMMAND
## and restores the layout after running the hooks.  When a empty value is
## specified, ble.sh assumes that these hooks do not output texts to the
## terminal and do not changes the cursor positions and skip the special
## treatment.

#bleopt prompt_command_changes_layout=   # PRECMD/PROMPT_COMMAND not output
#bleopt prompt_command_changes_layout=1  # PRECMD/PROMPT_COMMAND may output


## "exec_restore_pipestatus" controls whether ble.sh restores PIPESTATUS of the
## previous user command.  When this option is set to a non-empty value,
## PIPESTATUS is restored.  This feature is turned off by default because it
## adds extra execution costs.  Note that the values of PIPESTATUS of the
## previous command are always available with the array BLE_PIPESTATUS
## regardless of this setting.

#bleopt exec_restore_pipestatus=1  # restores PIPESTATUS


## "edit_marker" and "edit_marker_error" define the default styles of the
## markers [ble: ...] used by ble.sh.  "edit_marker" is used for the normal
## notifications, and "edit_marker_error" is used for the error information.
## When they are set to an empty string, those markers are disabled (unless
## additional information other than the markers needs to be output after the
## markers).  Those default styles can be overridden by specific mark settings,
## such as `exec_errexit_mark`, `exec_elapsed_mark`, and `exec_exit_mark`.

#bleopt edit_marker=$'\e[94m[ble: %s]\e[m'
#bleopt edit_marker_error=$'\e[91m[ble: %s]\e[m'


## "exec_errexit_mark" specifies the format of the mark to show the exit status
## of the command when it is non-zero.  If this setting is an empty string, the
## exit status will not be shown.  The value can contain ANSI escape sequences.

#bleopt exec_errexit_mark=$'\e[91m[ble: exit %d]\e[m'


## "exec_elapsed_mark" specifies the format of the command execution time
## report.  It takes two arguments: the first is the string that explains the
## elapsed time, and the second is a number that represents the percentage of
## CPU core usage.  "exec_elapsed_enabled" specifies the condition that the
## command execution time report is displayed after the command execution.  The
## condition is expressed by an arithmetic expression, where a non-zero result
## causes displaying the report.  In the arithmetic expression, variables
## "real", "{usr,sys}{,_self,_child}", and "cpu" can be used.  "real"
## represents the elapsed time.  "usr" and "sys" represent the user and system
## time, respectively.  The suffixes "_self" and "_child" represent the part
## consumed in the main shell process and the other child processes including
## subshells and external programs, respectively.  "cpu" represents the
## percentage of the CPU core usage in integer, which can be calculated by
## "(usr+sys)*100/real".  The other values are all in unit of milliseconds.

#bleopt exec_elapsed_mark=$'\e[94m[ble: elapsed %s (CPU %s%%)]\e[m'
#bleopt exec_elapsed_enabled='usr+sys>=10000'


## "exec_exit_mark" specifies the marker printed when the bash session ends.
## When an empty string is specified, the marker is disabled.

#bleopt exec_exit_mark=$'\e[94m[ble: exit]\e[m'


## The following setting controls the exit when jobs are remaining. When an
## empty string is set, the shell will never exit with remaining jobs through
## widgets. When an non-empty value is set, the shell will exit when exit is
## attempted twice consecutively.

#bleopt allow_exit_with_jobs=


## The following setting controls the default cursor position after moving to
## another history entry.  When "preserve" is specified, ble.sh tries to
## preserve the cursor position before moving the history entry.  When "begin"
## and "end" are specified, the cursor is placed at the beginning and end,
## respectively, of the entry.  When "near" is specified, when we move to an
## older (newer) history entry, the cursor is placed at the end (beginning) of
## the text.  When "far" is specified, when we move to an older (newer) history
## entry, the cursor is palced at the beginning (end) of the text.  When
## "beginning-of-{,graphical-,logical-}line" is specified, the cursor is placed
## at the beginning of the last (first) line when we move to an older (newer)
## history entry.  When "end-of-{,graphical-,logical-}line" is specified, the
## cursor is placed at the end of the last (first) line when we move to an
## older (newer) history entry.  When "preserve-{,graphical-,logical-}-column"
## is specified, te cursor is placed at the same column as before moving the
## history entry.  When the versions without "graphical" or "logical" is used,
## a logical or graphical line is used based on "bleopt edit_line_type".  The
## default is "end-of-line".  When "auto" is specified, the behavior is "end"
## by default, but it becomes similar to "near" when called by vi motion.

#bleopt history_default_point=auto


## The following setting controls the history sharing. If it has non-empty
## value, the history sharing is enabled. With the history sharing, the command
## history is shared with the other Bash ble.sh sessions with the history
## sharing turned on.

#bleopt history_share=


## This option controls the target range in the command history for
## "erasedups", which is performed when it is specified in "HISTCONTROL".  When
## this option has an empty value, the target range is the entire history as in
## the plain Bash.  When this option evaluates to a positive integer "count",
## the target range is the last "n" entries in the command history.  When this
## option evaluates to a non-positive integer "offset", "offset" specifies the
## beginning of the target range relative to the history count at the session
## start.  The end of the target range is always the end of the command
## history.

#bleopt history_erasedups_limit=       # entire history
#bleopt history_erasedups_limit=0      # only new items added in this session
#bleopt history_erasedups_limit=-1000  # new items and 1000 prev-session items
#bleopt history_erasedups_limit=1000   # last 1000 items


## The following setting controls the behavior of the widget
## "accept-single-line-or-newline" in the single-line editing mode. The value
## is a subject of arithmetic evaluation. When it evaluates to negative
## integers, the line is always accepted. When it evaluates to 0, it enters the
## multiline editing mode when there is any unprocessed user inputs, or
## otherwise the line is accepted. When it evaluates to a positive integer "n",
## it enters the multiline editing mode when there is more than "n"unprocessed
## user inputs.

#bleopt accept_line_threshold=5


## The following option controls the behavior when the number of characters
## exceeds the capacity specified by `line_limit_length`.  The value `none`
## means that the number of characters will not be checked.  The value
## `discard` means that the characters cannot be inserted when the number of
## characters exceeds the capacity.  The value `truncate` means that the
## command line is truncated from its end to fit into the capacity.  The value
## `editor` means that the widget `edit-and-execute` will be invoked to open an
## editor to edit the command line contents.  When the value `editor` is
## specified, `bleopt history_limit_length` is recommended to be less than or
## equal to `bleopt line_limit_length`.  Otherwise, the text editor may be
## unexpectedly executed in navigating through the history.

#bleopt line_limit_type=none


## The following option specifies the capacity of the command line in the
## number of characters.  The number 0 or negative numbers means the unlimited
## capacity.

#bleopt line_limit_length=10000


## The following option specifies the maximal number of characters which can be
## appended into the history.  When this option has a positive value, commands
## with the length longer than the value is not appended to the history.  When
## this option has a non-positive value, commands are always appended to the
## history regardless of their length.

#bleopt history_limit_length=10000


