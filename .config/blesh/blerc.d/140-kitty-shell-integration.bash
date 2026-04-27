# -*- mode: sh; mode: sh-bash -*-

##-----------------------------------------------------------------------------
## Kitty integration support

## Kitty's Bash integration can trigger prompt-command layout changes when
## used alongside ble.sh. Tell ble.sh to account for that layout movement.

bleopt prompt_command_changes_layout=1
