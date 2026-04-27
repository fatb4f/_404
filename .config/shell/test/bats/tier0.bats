#!/usr/bin/env bats

@test "clean bash sources load-env" {
	run env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash \
		bash --noprofile --norc -c '. "$HOME/.config/shell/load-env.sh"; test -n "$TOOL_PATH_HOME"'
	[ "$status" -eq 0 ]
}

@test "clean zsh sources load-env" {
	run env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/zsh \
		zsh -f -c '. "$HOME/.config/shell/load-env.sh"; test -n "$TOOL_PATH_HOME"'
	[ "$status" -eq 0 ]
}

@test "managed path resolves dotctl" {
	run env -i HOME="$HOME" USER="${USER:-user}" SHELL=/bin/bash \
		bash --noprofile --norc -c '. "$HOME/.config/shell/load-env.sh"; command -v dotctl'
	[ "$status" -eq 0 ]
}
