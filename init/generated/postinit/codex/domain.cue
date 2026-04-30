package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "2-agent"
	namespace: "AGENT"
	stage:     "20-agent"
	ring:      "agent"
	provider:  "npm_global"
	outputDir: "generated/postinit/codex"

	requires: [
		"terminal.ready",
		"tool.node",
		"tool.npm",
	]
	provides: [
		"domain.generated/postinit/codex",
		"agent.codex",
		"agent.shell-tool",
		"agent.shell-snapshot",
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
		prefix:    "$XDG_OPT_HOME/2-agent"
		state:     "$XDG_STATE_HOME/_404/2-agent"
		cache:     "$XDG_CACHE_HOME/_404/2-agent"
		binHome:   "$XDG_OPT_HOME/2-agent/bin"
		shareHome: "$XDG_OPT_HOME/2-agent/share"
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
		"id": "shell_tool",
		"source": "files/bin/shell_tool",
		"target": "$DOMAIN_PREFIX/bin/shell_tool",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "shell_snapshot",
		"source": "files/bin/shell_snapshot",
		"target": "$DOMAIN_PREFIX/bin/shell_snapshot",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "shell_tool",
		"source": "$DOMAIN_PREFIX/bin/shell_tool",
		"target": "$TOOL_PATH_HOME/shell_tool",
		"activation": "symlink",
		"role": "activated"
	},
	{
		"id": "shell_snapshot",
		"source": "$DOMAIN_PREFIX/bin/shell_snapshot",
		"target": "$TOOL_PATH_HOME/shell_snapshot",
		"activation": "symlink",
		"role": "activated"
	}
]
	checks: [
	{
		"id": "stage-ready",
		"command": "test -f $XDG_STATE_HOME/_404/bootstrap/20-agent.ready",
		"severity": "degraded"
	},
	{
		"id": "npm-available",
		"command": "command -v npm >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "codex-available",
		"command": "command -v codex >/dev/null 2>&1",
		"severity": "degraded"
	},
	{
		"id": "files-present",
		"command": "test -x $DOMAIN_PREFIX/bin/shell_tool && test -x $DOMAIN_PREFIX/bin/shell_snapshot",
		"severity": "fatal"
	},
	{
		"id": "shell-parse",
		"command": "sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/functions.sh",
		"severity": "fatal"
	}
]
}
