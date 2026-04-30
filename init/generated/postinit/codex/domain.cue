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
		"agent.codex.profile.slim",
		"agent.codex.hooks",
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
		"id": "config.toml",
		"source": "files/config.toml",
		"target": "$XDG_CONFIG_HOME/codex/config.toml",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "session-snapshot",
		"source": "files/hooks/session-snapshot",
		"target": "$XDG_CONFIG_HOME/codex/hooks/session-snapshot",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "pre-tool-use",
		"source": "files/hooks/pre-tool-use",
		"target": "$XDG_CONFIG_HOME/codex/hooks/pre-tool-use",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "post-tool-use",
		"source": "files/hooks/post-tool-use",
		"target": "$XDG_CONFIG_HOME/codex/hooks/post-tool-use",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "README.md",
		"source": "files/rules/README.md",
		"target": "$XDG_CONFIG_HOME/codex/rules/README.md",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "SKILL.md",
		"source": "files/skills/cue/SKILL.md",
		"target": "$XDG_CONFIG_HOME/codex/skills/cue/SKILL.md",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "_404-codex",
		"source": "files/bin/_404-codex",
		"target": "$DOMAIN_PREFIX/bin/_404-codex",
		"mode": "0755",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "_404-codex",
		"source": "$DOMAIN_PREFIX/bin/_404-codex",
		"target": "$TOOL_PATH_HOME/_404-codex",
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
		"id": "config-present",
		"command": "test -f $XDG_CONFIG_HOME/codex/config.toml",
		"severity": "fatal"
	},
	{
		"id": "hooks-present",
		"command": "test -x $XDG_CONFIG_HOME/codex/hooks/session-snapshot && test -x $XDG_CONFIG_HOME/codex/hooks/pre-tool-use && test -x $XDG_CONFIG_HOME/codex/hooks/post-tool-use",
		"severity": "fatal"
	},
	{
		"id": "launcher-present",
		"command": "test -x $DOMAIN_PREFIX/bin/_404-codex",
		"severity": "fatal"
	},
	{
		"id": "toml-parse",
		"command": "python3 -c 'import os,pathlib,tomllib; tomllib.loads(pathlib.Path(os.environ[\"XDG_CONFIG_HOME\"] + \"/codex/config.toml\").read_text())'",
		"severity": "fatal"
	},
	{
		"id": "hook-shell-parse",
		"command": "sh -n $XDG_CONFIG_HOME/codex/hooks/session-snapshot $XDG_CONFIG_HOME/codex/hooks/pre-tool-use $XDG_CONFIG_HOME/codex/hooks/post-tool-use $DOMAIN_PREFIX/bin/_404-codex",
		"severity": "fatal"
	}
]
}
