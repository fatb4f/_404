Describe 'tier0 shell env'
It 'loads under clean bash'
When run env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash \
	bash --noprofile --norc -c '. "$HOME/.config/shell/load-env.sh"; printf "%s\n" "$TOOL_PATH_HOME"'
The status should be success
The output should not be empty
End

It 'loads under clean zsh'
When run env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/zsh \
	zsh -f -c '. "$HOME/.config/shell/load-env.sh"; print -r -- "$TOOL_PATH_HOME"'
The status should be success
The output should not be empty
End

It 'resolves dotctl after loading env'
When run env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash \
	bash --noprofile --norc -c '. "$HOME/.config/shell/load-env.sh"; command -v dotctl'
The status should be success
End
End
