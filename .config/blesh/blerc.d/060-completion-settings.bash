# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Settings for completion


## The following settings turn on/off the corresponding functionalities. When
## non-empty strings are set, the functionality is enabled. Otherwise, the
## functionality is inactive.

bleopt complete_auto_complete=1
#bleopt complete_menu_complete=1
#bleopt complete_menu_filter=1


## If "complete_ambiguous" has non-empty values, ambiguous completion
## candidates are generated for completion.

#bleopt complete_ambiguous=1


## If "complete_contract_function_names" has non-empty values, the function
## name candidates are grouped by prefixes of the directory-like form "*/".

#bleopt complete_contract_function_names=1


## By default, ble.sh does not allow rewriting the existing text if non-unique
## candidates does not contain the existing text.  If this setting has
## non-empty values, ble.sh rewrites the existing text.

#bleopt complete_allow_reduction=1


## This option specifies the threshold to simplify the quotation type of the
## inserted word.  This option is evaluated as an arithmetic expression.  When
## this option evaluates to a negative value, the simplification of the
## quotation is disabled.  Otherwise, when the number of characters will be
## reduced by at least the specified value, the quotation is simplified.  The
## default is 0, which means that the quotation is simplified unless the number
## of characters increases by the simplification.

#bleopt complete_requote_threshold=0


## If "complete_auto_history" has non-empty values, auto-complete searches
## matching command lines from history.

bleopt complete_auto_history=1


## The following setting controls the delay of auto-complete after the last
## user input. The unit is millisecond.

#bleopt complete_auto_delay=100


## The face "auto_complete" can be used to specify the graphic style of the
## suggestion by auto-complete.  The default style is choosed just to make it
## work in both the terminals with light and dark backgrounds.  A better style
## can be specified based on the user's preference.

#ble-face auto_complete='fg=238,bg=254'           # default
#ble-face auto_complete='fg=231,bg=69'            # blue background
#ble-face auto_complete='fg=240,underline,italic' # darker background


## The setting "complete_auto_wordbreaks" is used as the delimiters for
## identifying words for M-right (auto-complete/insert-word).  The default
## value is $' \t\n'.  If the empty value is set, the default value is used.

#bleopt complete_auto_wordbreaks=$' \t\n/'


## The setting "complete_auto_complete_opts" is a colon-separated list of
## options.  When the option "history-disabled" is specified, the auto-complete
## source based on history is disabled.  When "suppress-after-complete" is
## included, auto-complete is disabled after TAB completions.  When
## "suppress-inside-line" is included, auto-complete is disabled when the
## character at the current cursor position, if any, is not a newline.  When
## "suppress-inside-word" is included, auto-complete is disabled when the
## character at the current cursor position, if any, is not included in the
## default COMP_WORDBREAKS.  When the option "syntax-disabled" is specified,
## the auto-complete source based on the syntax and programmable completion is
## disabled.  When "syntax-suppress-ambiguous" is specified, ambiguous
## completion is not attempted.  When "syntax-suppress-empty" is specified,
## syntax-based completion is suppressed for an empty word.  When the option
## "syntax-unique" is specified, the auto-complete source based on the syntax
## and programmable completion generates a candidate only when it is unique.

#bleopt complete_auto_complete_opts=


## The faces "menu_filter_fixed" and "menu_filter_input" can be used to specify
## the graphic styles of the part of the text that is used to filter the menu
## items by the menu-filter feature.

#ble-face menu_filter_fixed='bold'
#ble-face menu_filter_input='fg=16,bg=229'


## The setting "complete_auto_menu" controls the delay of "auto-menu".  When a
## non-empty string is set, auto-menu is enabled.  The string is evaluated as
## an arithmetic expression to give the delay in milliseconds.  ble.sh will
## automatically show the menu of completions after the idle time (for which
## user input does not arrive) reaches the delay.

#bleopt complete_auto_menu=500


## When there are user inputs while generating completion candidates, the
## candidates generation will be canceled to process the user inputs. The
## following setting controls the interval of checking user inputs while
## generating completion candidates.

#bleopt complete_polling_cycle=50


## A hint on the maximum acceptable size of any data structure generated during
## the completion process, beyond which the completion may be prematurely
## aborted to avoid excessive processing time.  "complete_limit" is used for
## TAB completion.  When its value is empty, the size checks are disabled.
## "complete_limit_auto" is used for auto-completion.  When its value is empty,
## the setting "complete_limit" is used instead. "complete_limit_auto_menu" is
## used for auto-menu.

#bleopt complete_limit=500
#bleopt complete_limit_auto=200
#bleopt complete_limit_auto_menu=100


## The following setting controls the timeout for the pathname expansions
## performed in auto-complete.  When the word contains a glob pattern that
## takes a long time to evaluate the pathname expansion, auto-complete based on
## the filename is canceled based on the timeout setting.  The value specifies
## the timeout duration in milliseconds.  When the value is empty, the
## timeout is disabled.

#bleopt complete_timeout_auto=5000


## The following setting controls the timeout for the pathname expansions to
## prepare COMP_WORDS and COMP_LINE for progcomp.  When the word contains a
## glob pattern that takes a long time to evaluate, the pathname expansion is
## canceled, and a noglob expansion is used to construct COMP_WORDS and
## COMP_LINE.  The value specifies ## the timeout duration in milliseconds.
## When the value is empty, the timeout is disabled.

#bleopt complete_timeout_compvar=200


## The following setting specifies the style of the menu to show completion
## candidates. The value "dense" and "dense-nowrap" shows candidates separated
## by spaces. "dense-nowrap" is different from "dense" in the behavior that it
## inserts a new line before the candidates that does not fit into the
## remaining part of the current line. The value "align" and "align-nowrap"
## aligns the candidates. The value "linewise" shows a candidate per line.  The
## value "desc" and "desc-text" shows a candidate per line with description for
## each. "desc-text" is different from "desc" in the behavior that it does not
## interprets ANSI escape sequences in the descriptions.

#bleopt complete_menu_style=align-nowrap


## When a non-empty value is specified to this setting, the matching text on
## the right of the cursor is removed on the insertion of the completion.  This
## setting is synchronized with the readline variable "skip-completed-text".

#bleopt complete_skip_matched=on


## The following setting controls the detailed behavior of menu-complete with a
## colon-separated list of options.  When the option "insert-selection" is
## specified, the currently selected menu item is temporarily inserted in the
## command line.  When "hidden" is specified, "insert-selection" is enabled,
## and additionally, the completion menu is hidden by default.  The default is
## "insert-selection".

#bleopt complete_menu_complete_opts=insert-selection


## When a non-empty value is specified to this setting, the highlighting of the
## menu items is enabled.  This setting is synchronized with the readline
## variable "colored-stats".

#bleopt complete_menu_color=on


## When a non-empty value is specified to this setting, the part of the menu
## items matching with the already input text is highlighted.  This setting is
## synchronized with the readline variable "colored-completion-prefix".

#bleopt complete_menu_color_match=on


## The following settings specify the maximal and minimal align widths for
## complete_menu_style="align" and "align-nowrap".

#bleopt menu_align_min=4
#bleopt menu_align_max=20


## The following setting specifies the maximal height of the menu.  When this
## value is evaluated to be a positive integer, the maximal line number of the
## menu is limited to that value.

#bleopt complete_menu_maxlines=10


## The following settings specify the prefix of the menu items.  "menu_prefix"
## specifies the default prefix for any menu-style.
## "menu_{align,desc,linewise,dense}_prefix" specify the prefixes in the
## respective menu-styles.  The value is specified by a printf format, where
## the first argument is the index of the candidate.  ANSI escape sequences can
## also be used.  For example, the candidate index can be shown by setting the
## value '%d '.  The default value is empty.

#bleopt menu_align=
#bleopt menu_align_prefix='\e[1m%d:\e[m '
#bleopt menu_desc_prefix='\e[1m%d.\e[m '
#bleopt menu_linewise_prefix='\e[1;36m%d:\e[m '
#bleopt menu_dense_prefix='\e[1;32m>\e[m '


## The following setting specifies the minimum column width for the multicolumn
## description for `complete_menu_style=desc'.  When the empty value is
## specified, the multicolumn mode is disabled.

#bleopt menu_desc_multicolumn_width=65


## These faces specifies additional graphic styles used to highlight completion
## candidates.  Face "menu_complete_match" specifies the additional style for
## the candidate parts matching the filtering text.  Face
## "menu_complete_selected" specifies the additional style for the selected
## candidate.

#ble-face menu_complete_match=bold
#ble-face menu_complete_selected=reverse


## These faces control graphic styles used in the menu descriptions.  Face
## "menu_desc_default" is used as a default highlighting of the description.
## Face "menu_desc_type" is used for the prefix string "(type) " to indicate
## the type of the menu item.  Face "menu_desc_quote" is used to quote strings
## embedded in the descriptions.

#ble-face menu_desc_default=none
#ble-face menu_desc_type=ref:syntax_delimiter
#ble-face menu_desc_quote=ref:syntax_quoted


## When this Readline setting is enabled, the cases of alphabets are ignored on
## completion generation.

#bind 'set completion-ignore-case off'


## When this Readline setting is turned on, suffixes are added to the filename
## completions in the menu.  The characters "@", "/" and "*" are added to
## symbolic links, directories and executables, respectively.

#bind 'set visible-stats off'


## When this Readline setting is turned on, the suffix "/" is inserted after
## the insertion of directory names.

#bind 'set mark-directories on'


## When this Readline setting is turned on, the suffix "/" is inserted after
## symbolic links pointing to directories.

#bind 'set mark-symlinked-directories on'


## When this Readline setting is turned on, the filenames starting with "." is
## also generated as possible completions.

#bind 'set match-hidden-files on'


## By default, when filenames of the form "dir/file*" is shown in the menu, the
## part of the directory name "dir/" is omitted.  When this Readline setting is
## turned on, the directory name of filename completions are not omitted.

#bind 'set menu-complete-display-prefix off'


## This option specifies a colon-separated list of glob patterns of sabbrev
## names ignored in generating the sabbrev completion candidates.

#bleopt complete_source_sabbrev_ignore=


## This is a colon-separated list of options.  When the field
## `no-empty-completion` is specified, the sabbrev completion candidates are
## not generated when the word to complete is empty.

#bleopt complete_source_sabbrev_opts=no-empty-completion

