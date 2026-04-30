package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "1-terminal"
	namespace: "TERMINAL"
	stage:     "10-terminal"
	ring:      "terminal"
	provider:  "host_pkg"
	outputDir: "generated/init/term/kitty"

	requires: [
		"shell.bootstrap.ready",
		"shell.interactive.ready",
	]
	provides: [
		"domain.generated/init/term/kitty",
		"terminal.kitty",
		"terminal.ready",
	]

	roots: {
		dots_repo:  "src"
		dots_dir:   "dots"
		dots:       "$XDG_DATA_HOME/_404/dots"
		xdg_config: "$DOTS_HOME/.config"
		xdg_data:   "$HOME/.local/share"
		xdg_opt:    "$DOTS_HOME/.local/opt"
		xdg_state:  "$HOME/.local/state"
		xdg_cache:  "$HOME/.cache"
		tool_path:  "$HOME/.local/bin"
	}

	paths: {
		prefix:    "$XDG_OPT_HOME/1-terminal"
		state:     "$XDG_STATE_HOME/_404/1-terminal"
		cache:     "$XDG_CACHE_HOME/_404/1-terminal"
		binHome:   "$XDG_OPT_HOME/1-terminal/bin"
		shareHome: "$XDG_OPT_HOME/1-terminal/share"
	}

	owns: [
	{
		"id": "env.sh",
		"source": "files/env.sh",
		"target": "$DOMAIN_PREFIX/env.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "init.sh",
		"source": "files/init.sh",
		"target": "$DOMAIN_PREFIX/init.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "functions.sh",
		"source": "files/functions.sh",
		"target": "$DOMAIN_PREFIX/functions.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "kitty.conf",
		"source": "files/kitty.conf",
		"target": "$DOMAIN_PREFIX/kitty/kitty.conf",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "overrides.kitty.conf",
		"source": "files/overrides.kitty.conf",
		"target": "$DOMAIN_PREFIX/kitty/overrides.kitty.conf",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "kitty-t0",
		"source": "files/bin/kitty-t0",
		"target": "$DOMAIN_PREFIX/bin/kitty-t0",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "kitty-launch-with-cwd",
		"source": "files/bin/kitty-launch-with-cwd",
		"target": "$DOMAIN_PREFIX/bin/kitty-launch-with-cwd",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "kitty-launch-desktop",
		"source": "files/bin/kitty-launch-desktop",
		"target": "$DOMAIN_PREFIX/bin/kitty-launch-desktop",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "kitty-zsh-max",
		"source": "files/bin/kitty-zsh-max",
		"target": "$DOMAIN_PREFIX/bin/kitty-zsh-max",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "stage-kitty.desktop",
		"source": "files/applications/stage-kitty.desktop",
		"target": "$DOMAIN_PREFIX/applications/stage-kitty.desktop",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "stage-kitty-workflow.desktop",
		"source": "files/applications/stage-kitty-workflow.desktop",
		"target": "$DOMAIN_PREFIX/applications/stage-kitty-workflow.desktop",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "kitty.conf",
		"source": "$DOMAIN_PREFIX/kitty/kitty.conf",
		"target": "$XDG_CONFIG_HOME/kitty/kitty.conf",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "overrides.kitty.conf",
		"source": "$DOMAIN_PREFIX/kitty/overrides.kitty.conf",
		"target": "$XDG_CONFIG_HOME/kitty/overrides.kitty.conf",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "kitty-t0",
		"source": "$DOMAIN_PREFIX/bin/kitty-t0",
		"target": "$TOOL_PATH_HOME/kitty-t0",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "kitty-launch-with-cwd",
		"source": "$DOMAIN_PREFIX/bin/kitty-launch-with-cwd",
		"target": "$TOOL_PATH_HOME/kitty-launch-with-cwd",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "kitty-launch-desktop",
		"source": "$DOMAIN_PREFIX/bin/kitty-launch-desktop",
		"target": "$TOOL_PATH_HOME/kitty-launch-desktop",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "kitty-zsh-max",
		"source": "$DOMAIN_PREFIX/bin/kitty-zsh-max",
		"target": "$TOOL_PATH_HOME/kitty-zsh-max",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "stage-kitty.desktop",
		"source": "$DOMAIN_PREFIX/applications/stage-kitty.desktop",
		"target": "$XDG_DATA_HOME/applications/stage-kitty.desktop",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "stage-kitty-workflow.desktop",
		"source": "$DOMAIN_PREFIX/applications/stage-kitty-workflow.desktop",
		"target": "$XDG_DATA_HOME/applications/stage-kitty-workflow.desktop",
		"activation": "symlink",
		"role": "activated"
	}
]
	checks: [
	{
		"id": "stage-ready",
		"command": "test -f $XDG_STATE_HOME/_404/bootstrap/10-terminal.ready",
		"severity": "degraded"
	},
	{
		"id": "files-present",
		"command": "test -f $DOMAIN_PREFIX/kitty/kitty.conf && test -x $DOMAIN_PREFIX/bin/kitty-t0",
		"severity": "degraded"
	},
	{
		"id": "shell-parse",
		"command": "sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/functions.sh $DOMAIN_PREFIX/bin/kitty-launch-desktop $DOMAIN_PREFIX/bin/kitty-zsh-max",
		"severity": "fatal"
	},
	{
		"id": "kitty-available",
		"command": "command -v kitty >/dev/null 2>&1",
		"severity": "warning"
	}
]
}
