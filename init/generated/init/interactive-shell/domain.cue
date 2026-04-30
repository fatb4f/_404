package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "generated/init/interactive-shell"
	namespace: "INTERACTIVE_SHELL"
	stage:     "interactive-shell"
	ring:      "substrate"
	provider:  "domain_local"
	outputDir: "generated/init/interactive-shell"

	requires: [
		"tool.zsh",
		"shell.bootstrap.ready",
	]
	provides: [
		"domain.generated/init/interactive-shell",
		"shell.interactive.ready",
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
		prefix:    "$XDG_OPT_HOME/0-interactive-shell"
		state:     "$XDG_STATE_HOME/_404/0-interactive-shell"
		cache:     "$XDG_CACHE_HOME/_404/0-interactive-shell"
		binHome:   "$XDG_OPT_HOME/0-interactive-shell/bin"
		shareHome: "$XDG_OPT_HOME/0-interactive-shell/share"
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
		"id": "zshenv",
		"source": "files/zshenv",
		"target": "$HOME/.zshenv",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	},
	{
		"id": "zshrc",
		"source": "files/zshrc",
		"target": "$HOME/.zshrc",
		"mode": "0644",
		"activation": "atomic-copy",
		"role": "projected"
	}
]
	checks: [
	{
		"id": "zsh-available",
		"command": "command -v zsh >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "zshenv-parse",
		"command": "test -f $HOME/.zshenv && zsh -n $HOME/.zshenv",
		"severity": "fatal"
	},
	{
		"id": "zshrc-parse",
		"command": "test -f $HOME/.zshrc && zsh -n $HOME/.zshrc",
		"severity": "fatal"
	},
	{
		"id": "stage-ready",
		"command": "test -f $XDG_STATE_HOME/_404/bootstrap/interactive-shell.ready",
		"severity": "degraded"
	}
]
}
