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
		dots:       "$XDG_DATA_HOME/_404/dots"
		xdg_config: "$DOTS_HOME/.config"
		xdg_data:   "$HOME/.local/share"
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
		"id": "loader.sh",
		"source": "files/init/loader.sh",
		"target": "$DOTS_HOME/.config/init/loader.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "check.sh",
		"source": "files/init/check.sh",
		"target": "$DOTS_HOME/.config/init/check.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "env.sh",
		"source": "files/init/env.sh",
		"target": "$DOTS_HOME/.config/init/env.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "path.sh",
		"source": "files/init/path.sh",
		"target": "$DOTS_HOME/.config/init/path.sh",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "bash_profile",
		"source": "files/bash_profile",
		"target": "$DOTS_HOME/.bash_profile",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "bashrc",
		"source": "files/bashrc",
		"target": "$DOTS_HOME/.bashrc",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "bash_env",
		"source": "files/bash_env",
		"target": "$DOTS_HOME/.bash_env",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "profile",
		"source": "files/profile",
		"target": "$DOTS_HOME/.profile",
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
		"command": "test -f $DOMAIN_PREFIX/init.sh && test -f $DOMAIN_PREFIX/env.sh && test -f $DOMAIN_PREFIX/path.sh && test -f $DOMAIN_PREFIX/require.sh && test -f $XDG_CONFIG_HOME/_404/env.sh && test -f $DOTS_HOME/.config/init/loader.sh && test -f $DOTS_HOME/.config/init/check.sh && test -f $DOTS_HOME/.config/init/env.sh && test -f $DOTS_HOME/.config/init/path.sh && test -f $DOTS_HOME/.bash_profile && test -f $DOTS_HOME/.bashrc && test -f $DOTS_HOME/.bash_env && test -f $DOTS_HOME/.profile",
		"severity": "fatal"
	},
	{
		"id": "shell-parse",
		"command": "sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/path.sh $DOMAIN_PREFIX/require.sh $XDG_CONFIG_HOME/_404/env.sh $DOTS_HOME/.config/init/loader.sh $DOTS_HOME/.config/init/check.sh $DOTS_HOME/.config/init/env.sh $DOTS_HOME/.config/init/path.sh $DOTS_HOME/.bash_profile $DOTS_HOME/.bashrc $DOTS_HOME/.bash_env $DOTS_HOME/.profile",
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
		"command": "test -f $DOTS_HOME/.bash_profile && sh -n $DOTS_HOME/.bash_profile",
		"severity": "fatal"
	},
	{
		"id": "bashrc-parse",
		"command": "test -f $DOTS_HOME/.bashrc && sh -n $DOTS_HOME/.bashrc",
		"severity": "fatal"
	},
	{
		"id": "bash_env-parse",
		"command": "test -f $DOTS_HOME/.bash_env && sh -n $DOTS_HOME/.bash_env",
		"severity": "fatal"
	},
	{
		"id": "profile-parse",
		"command": "test -f $DOTS_HOME/.profile && sh -n $DOTS_HOME/.profile",
		"severity": "fatal"
	},
	{
		"id": "init-loader-parse",
		"command": "test -f $DOTS_HOME/.config/init/loader.sh && sh -n $DOTS_HOME/.config/init/loader.sh && test -f $DOTS_HOME/.config/init/check.sh && sh -n $DOTS_HOME/.config/init/check.sh && test -f $DOTS_HOME/.config/init/env.sh && sh -n $DOTS_HOME/.config/init/env.sh && test -f $DOTS_HOME/.config/init/path.sh && sh -n $DOTS_HOME/.config/init/path.sh",
		"severity": "fatal"
	}
]
}
