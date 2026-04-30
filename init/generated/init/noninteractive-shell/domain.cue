package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "0-noninteractive-shell"
	namespace: "NONINTERACTIVE_SHELL"
	stage:     "00-shell"
	ring:      "substrate"
	provider:  "domain_local"
	outputDir: "generated/init/noninteractive-shell"

	requires: [
		"tool.sh",
	]
	provides: [
		"domain.generated/init/noninteractive-shell",
		"shell.noninteractive",
		"shell.bootstrap.ready",
	]

	roots: {
		dots_repo:  "src"
		dots_dir:   "dots"
		dots:       "$HOME/$DOTS_REPO/$DOTS_DIR"
		xdg_config: "$DOTS_HOME/.config"
		xdg_data:   "$DOTS_HOME/.local/share"
		xdg_opt:    "$DOTS_HOME/.local/opt"
		xdg_state:  "$HOME/.local/state"
		xdg_cache:  "$HOME/.cache"
		tool_path:  "$HOME/.local/bin"
	}

	paths: {
		prefix:    "$XDG_OPT_HOME/0-noninteractive-shell"
		state:     "$XDG_STATE_HOME/_404/0-noninteractive-shell"
		cache:     "$XDG_CACHE_HOME/_404/0-noninteractive-shell"
		binHome:   "$XDG_OPT_HOME/0-noninteractive-shell/bin"
		shareHome: "$XDG_OPT_HOME/0-noninteractive-shell/share"
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
		"id": "env-loader.sh",
		"source": "files/env-loader.sh",
		"target": "$XDG_CONFIG_HOME/_404/env.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "bash_profile",
		"source": "files/bash_profile",
		"target": "$HOME/.bash_profile",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "bashrc",
		"source": "files/bashrc",
		"target": "$HOME/.bashrc",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "path.sh",
		"source": "files/path.sh",
		"target": "$DOMAIN_PREFIX/path.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "require.sh",
		"source": "files/require.sh",
		"target": "$DOMAIN_PREFIX/require.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	}
]
	checks: [
	{
		"id": "stage-ready",
		"command": "test -f $XDG_STATE_HOME/_404/bootstrap/00-shell.ready",
		"severity": "fatal"
	},
	{
		"id": "files-present",
		"command": "test -f $DOMAIN_PREFIX/init.sh && test -f $DOMAIN_PREFIX/env.sh && test -f $DOMAIN_PREFIX/path.sh && test -f $DOMAIN_PREFIX/require.sh && test -f $XDG_CONFIG_HOME/_404/env.sh && test -f $HOME/.bash_profile && test -f $HOME/.bashrc",
		"severity": "fatal"
	},
	{
		"id": "shell-parse",
		"command": "sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/path.sh $DOMAIN_PREFIX/require.sh $XDG_CONFIG_HOME/_404/env.sh $HOME/.bash_profile $HOME/.bashrc",
		"severity": "fatal"
	},
	{
		"id": "bash-available",
		"command": "command -v bash >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "env-loader-parse",
		"command": "test -f $XDG_CONFIG_HOME/_404/env.sh && sh -n $XDG_CONFIG_HOME/_404/env.sh",
		"severity": "fatal"
	},
	{
		"id": "bash_profile-parse",
		"command": "test -f $HOME/.bash_profile && sh -n $HOME/.bash_profile",
		"severity": "fatal"
	},
	{
		"id": "bashrc-parse",
		"command": "test -f $HOME/.bashrc && sh -n $HOME/.bashrc",
		"severity": "fatal"
	}
]
}
