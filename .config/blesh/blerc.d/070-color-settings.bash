# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Color settings

## The setting "term_index_colors" specifies the number of index colors used to
## specify colors in the terminal.  The value "auto" means that the use of
## index colors are determined based on the terminfo database and the value of
## TERM shell variable.  Otherwise, the value is evaluated as an arithmetic
## expression.  When it is evaluated to 256, the index colors are assumed to be
## xterm 256-color palette (16 basic + 6x6x6 color cube + 24 gray scale).  When
## it is evaluated to 88, the index colors are assumed to be xterm 88-color
## palette (16 basic + 4x4x4 color cube + 8 gray scale).  When it is evaluated
## to 0, ble.sh will never use the index colors to set colors.  When it is
## evaluated to other integers, the value specifies the maximum available
## index.

#bleopt term_index_colors=256


## The setting "term_true_colors" specifies the format of 24-bit color escape
## sequences supported by your terminal.  The value "semicolon" indicates the
## format "CSI 3 8 ; 2 ; R ; G ; B m".  The value "colon" indicates the format
## "CSI 3 8 : 2 : R : G : B m".  The other value implies that the terminal does
## not support 24-bit color sequences.  In this case, ble.sh tries to output
## indexed color sequences or basic color sequences with properly reduced
## colors.

#bleopt term_true_colors=semicolon


## The setting "filename_ls_colors" can be used to import the filename coloring
## scheme by the environment variable LS_COLORS.

#bleopt filename_ls_colors="$LS_COLORS"


## The following settings enable or disable the syntax highlighting.  When the
## setting "highlight_syntax" has a non-empty value, the syntax highlighting is
## enabled.  When the setting "highlight_filename" has a non-empty value, the
## highlighting based on the filename and the command name is enabled during
## the process of the syntax highlighting.  Similarly, when the setting
## "highlight_variable" has a non-empty value, the highlighting based on the
## variable type is enabled.  All of these settings have non-empty values by
## default.

#bleopt highlight_syntax=
#bleopt highlight_filename=
#bleopt highlight_variable=


## The following settings control the timeout and user-input cancellation of
## the pathname expansions performed in the syntax highlighting.  When the word
## contains a glob pattern that takes a long time to evaluate the pathname
## expansion, the syntax highlighting based on the filename is canceled based
## on the timeouts specified by these settings.  "highlight_timeout_sync" /
## "highlight_timeout_async" specify the timeout durations in milliseconds to
## be used for the foreground / background syntax highlighting, respectively.
## When the timeout occurred in the foreground, the syntax highlighting will be
## deferred to the background syntax highlighting.  When the timeout occurred
## in the background, the syntax highlighting for the filename is canceled.
## When the value is empty, the corresponding timeout is disabled.
## "syntax_eval_polling_interval" specifies the maximal interval between the
## user-input checking.

#bleopt highlight_timeout_sync=500
#bleopt highlight_timeout_async=5000
#bleopt syntax_eval_polling_interval=50


## The following setting limits the number of expanded words to process in
## highlighting a single grammatical word.  When this setting is set to an
## empty string, the number of expanded words to process is unlimited.

#bleopt highlight_eval_word_limit=200


## If set to a non-empty value, the setting "color_scheme" specifies a preset
## graphic styles for basic faces.  The supported schemes are found in the
## subdirectory "contrib/scheme".  The default value is "default".

#bleopt color_scheme=base16


## The following settings specify graphic styles of corresponding faces.  Faces
## used for specific features are described in the respective sections.

#ble-face -s region                    fg=231,bg=60
#ble-face -s region_insert             fg=27,bg=254
#ble-face -s region_match              fg=231,bg=55
#ble-face -s region_target             fg=black,bg=153
#ble-face -s disabled                  fg=242
#ble-face -s overwrite_mode            fg=black,bg=51

#ble-face -s syntax_default            none
#ble-face -s syntax_command            fg=brown
#ble-face -s syntax_quoted             fg=green
#ble-face -s syntax_quotation          fg=green,bold
#ble-face -s syntax_escape             fg=magenta
#ble-face -s syntax_expr               fg=63
#ble-face -s syntax_error              bg=203,fg=231
#ble-face -s syntax_varname            fg=202
#ble-face -s syntax_delimiter          bold
#ble-face -s syntax_param_expansion    fg=133
#ble-face -s syntax_history_expansion  bg=94,fg=231
#ble-face -s syntax_function_name      fg=99,bold
#ble-face -s syntax_comment            fg=gray
#ble-face -s syntax_glob               fg=198,bold
#ble-face -s syntax_brace              fg=37,bold
#ble-face -s syntax_tilde              fg=63,bold
#ble-face -s syntax_document           fg=100
#ble-face -s syntax_document_begin     fg=100,bold
#ble-face -s command_builtin_dot       fg=red,bold
#ble-face -s command_builtin           fg=red
#ble-face -s command_alias             fg=teal
#ble-face -s command_function          fg=99 # fg=133
#ble-face -s command_file              fg=green
#ble-face -s command_keyword           fg=blue
#ble-face -s command_jobs              fg=red,bold
#ble-face -s command_directory         fg=63,underline
#ble-face -s command_suffix            fg=231,bg=28
#ble-face -s command_suffix_new        fg=231,bg=124
#ble-face -s argument_option           fg=teal
#ble-face -s argument_option           fg=black,bg=225
#ble-face -s filename_directory        underline,fg=33
#ble-face -s filename_directory_sticky underline,fg=231,bg=26
#ble-face -s filename_link             underline,fg=teal
#ble-face -s filename_orphan           underline,fg=16,bg=224
#ble-face -s filename_setuid           underline,fg=black,bg=220
#ble-face -s filename_setgid           underline,fg=black,bg=191
#ble-face -s filename_executable       underline,fg=green
#ble-face -s filename_other            underline
#ble-face -s filename_socket           underline,fg=cyan,bg=black
#ble-face -s filename_pipe             underline,fg=lime,bg=black
#ble-face -s filename_character        underline,fg=231,bg=black
#ble-face -s filename_block            underline,fg=yellow,bg=black
#ble-face -s filename_warning          underline,fg=red
#ble-face -s filename_url              underline,fg=blue
#ble-face -s filename_ls_colors        underline
#ble-face -s varname_array             fg=orange,bold
#ble-face -s varname_empty             fg=31
#ble-face -s varname_export            fg=200,bold
#ble-face -s varname_expr              fg=99,bold
#ble-face -s varname_hash              fg=70,bold
#ble-face -s varname_new               fg=34
#ble-face -s varname_number            fg=64
#ble-face -s varname_readonly          fg=200
#ble-face -s varname_transform         fg=29,bold
#ble-face -s varname_unset             fg=245

#ble-face -s cmdinfo_cd_cdpath         fg=26,bg=155

