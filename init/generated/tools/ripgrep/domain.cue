package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "ripgrep"
	namespace: "RIPGREP"
	stage:     "43-ripgrep"
	ring:      "workflow"
	provider:  "cargo_binstall"
	outputDir: "generated/tools/ripgrep"

	requires: []
	provides: [
		"domain.generated/tools/ripgrep",
		"tool.rg",
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
		prefix:    "$XDG_OPT_HOME/ripgrep"
		state:     "$XDG_STATE_HOME/_404/ripgrep"
		cache:     "$XDG_CACHE_HOME/_404/ripgrep"
		binHome:   "$XDG_OPT_HOME/ripgrep/bin"
		shareHome: "$XDG_OPT_HOME/ripgrep/share"
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
	}
]
	checks: [
	{
		"id": "rg-available",
		"command": "command -v rg >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cargo-available",
		"command": "command -v cargo >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cargo-binstall-available",
		"command": "command -v cargo-binstall >/dev/null 2>&1",
		"severity": "degraded"
	},
	{
		"id": "rg-version",
		"command": "rg --version >/dev/null 2>&1",
		"severity": "fatal"
	}
]
}
