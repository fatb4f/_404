package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "cue"
	namespace: "CUE"
	stage:     "41-cue"
	ring:      "workflow"
	provider:  "domain_local"
	outputDir: "generated/tools/cue"

	requires: []
	provides: [
		"domain.generated/tools/cue",
		"tool.cue",
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
		prefix:    "$XDG_OPT_HOME/cue"
		state:     "$XDG_STATE_HOME/_404/cue"
		cache:     "$XDG_CACHE_HOME/_404/cue"
		binHome:   "$XDG_OPT_HOME/cue/bin"
		shareHome: "$XDG_OPT_HOME/cue/share"
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
		"id": "cue-available",
		"command": "command -v cue >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cue-version",
		"command": "cue version >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cue-vet-help",
		"command": "cue vet --help >/dev/null 2>&1",
		"severity": "fatal"
	}
]
}
