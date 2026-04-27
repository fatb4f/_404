# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Internal settings


## When the option "connect_tty" is set to a non-empty value, ble.sh in the
## child interactive Bash processes tries to connect to /dev/tty for its user
## interface when the initial standard streams of Bash are redirected to
## non-TTY streams.  The standard streams for the user command executions are
## kept to be the original ones.  This does not affect the behavior of the
## current session.  If it is set to the value "inherit", ble.sh tries to
## export the TTY for the child ble.sh sessions.  This might cause an issue in
## non-closing terminal window when a background process starts in the session.
## The default value is "1".

#bleopt connect_tty=


## This option sets the interval of checking new user inputs.  The value is
## evaluated as an arithmetic expression.  On the evaluation, a shell variable
## "ble_util_idle_elapsed" is provided for the time since the last user input
## in millisecond.  This option is used for the polling for the background
## execution when there is no user inputs.

#bleopt idle_interval='ble_util_idle_elapsed>600000?500:(ble_util_idle_elapsed>60000?200:(ble_util_idle_elapsed>5000?100:20))'


## This option specifies a colon-separated list of custom search paths of "ble-import".

#bleopt import_path="${XDG_DATA_HOME:-$HOME/.local/share}/blesh/local"


## When a non-empty value is specified to this option, displays the internal
## syntax analysis information and the syntax tree.  This is only effective in
## devel versions.

#bleopt syntax_debug=


## When the option "debug_xtrace" contains a non-empty value, xtrace (set -x)
## is enabled for the internal processing of ble.sh.  The value is used for the
## xtrace output log filename. [ Caution: The file size of the log file can
## soon grow up to hundred megabytes or to gigabytes. ]  The option
## "debug_xtrace_ps4" specifies the value of PS4 for xtrace enabled by
## "debug_xtrace".

#bleopt debug_xtrace=~/blesh.xtrace
#bleopt debug_xtrace_ps4='+ '


## When the option "debug_idle" contains a non-empty value, the background
## tasks currently running are shown in the info panel.

#bleopt debug_idle=1


## [The setting "openat_base" needs to be set before ble.sh is loaded or
## specified in the source options.  Therefore the value should be assigned
## directly to the shell variable "bleopt_openat_base" instead of using
## "bleopt" command.]
##
## This setting "openat_base" specifies the starting number of the file
## descriptors which ble.sh internally uses in Bash 4.0 or lower.  The value of
## this setting is used as the number for the first file descriptor of internal
## use, and the next value is used for the second file descriptor, and so on.
## When you want to use the default value 30 and succeeding number 31, 32,
## etc. for other purposes, please set to this settings another value which
## does not conflict with file descriptors of other purposes.

# echo "usage: e.g. source out/ble.sh -o openat_base=30"


## This option specifies the context of the command execution.  The value
## "gexec" specifies that the user command is evaluated in global contexts.
## The value "exec" (ble-0.3 and before) specified that the user command is
## evaluated in a function, but the support is removed in ble-0.4 because this
## is only remained for a debugging purpose and not tested well.

#bleopt internal_exec_type=gexec


## If this option has a non-empty value, when the execution of a shell function
## is interrupted by SIGINT, the processing of SIGINT by the DEBUG trap is
## printed to stderr.  The default is empty.

#bleopt internal_exec_int_trace=1


## This option sets the message that Bash outputs when "C-d" is input by user.
## This value is used to detect that the user inputs "C-d" in Bash 3.

#bleopt internal_ignoreeof_trap='Use "exit" to leave the shell.'


## This option controls the output of stack dump when assertion is failed in
## ble.sh.  When the value is evaluated to be non-zero, the stack dump is
## printed for assertion failures.

#bleopt internal_stackdump_enabled=0


## When a non-empty value is specified to this option, the standard output and
## standard error from Bash is not output to the terminal.  When the value is
## empty, ble.sh tries to realize the line editing allowing Bash to output its
## own standard output and error.  This setting has a flickering problem and
## only left for debugging purpose, so it is not tested.  Normally a non-empty
## value should be specified so as to suppress the standard output and error
## from Bash.

#bleopt internal_suppress_bash_output=1


## This is a colon-separated list of fields to control the behavior of
## ble/debug/profiler.  When the field "line" and "func" are specified,
## statistics for lines and function calls, respectively, are enabled.  When
## the field "tree" is specified, function-call trees are saved.  Optional
## parameter "html" can be specified to "line" and "func" separated by the
## equal sign, i.e., "line=html" and "func=html".  In such a case, the results
## are also saved in the .html format.

#bleopt debug_profiler_opts=line:func


## This option specifies the threshold time in milliseconds to determine
## whether to include a command in the tree generated by "bleopt
## debug_profiler_opts=tree".  The commands that took less than this time in
## execution will be skipped.  The default value is 5.0 msec.

#bleopt debug_profiler_tree_threshold=5.0
