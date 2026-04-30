package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "go"
	namespace: "GO"
	stage:     "40-tools"
	ring:      "workflow"
	provider:  "host_pkg"
	outputDir: "generated/tools/go"

	requires: []
	provides: [
		"domain.generated/tools/go",
		"tool.go",
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
		prefix:    "$XDG_OPT_HOME/go"
		state:     "$XDG_STATE_HOME/_404/go"
		cache:     "$XDG_CACHE_HOME/_404/go"
		binHome:   "$XDG_OPT_HOME/go/bin"
		shareHome: "$XDG_OPT_HOME/go/share"
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
		"id": "go-available",
		"command": "command -v go >/dev/null 2>&1",
		"severity": "fatal"
	}
]
}
