package domain

import "stage.local/src/schema"

domain: schema.#Domain & {
	id:        "rust"
	namespace: "RUST"
	stage:     "42-rust"
	ring:      "workflow"
	provider:  "host_pkg"
	outputDir: "generated/tools/rust"

	requires: []
	provides: [
		"domain.generated/tools/rust",
		"tool.rustc",
		"tool.cargo",
		"tool.rustfmt",
		"tool.clippy-driver",
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
		prefix:    "$XDG_OPT_HOME/rust"
		state:     "$XDG_STATE_HOME/_404/rust"
		cache:     "$XDG_CACHE_HOME/_404/rust"
		binHome:   "$XDG_OPT_HOME/rust/bin"
		shareHome: "$XDG_OPT_HOME/rust/share"
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
		"id": "rustc-available",
		"command": "command -v rustc >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cargo-available",
		"command": "command -v cargo >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "rustfmt-available",
		"command": "command -v rustfmt >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "clippy-driver-available",
		"command": "command -v clippy-driver >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "rustc-version",
		"command": "rustc --version >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cargo-version",
		"command": "cargo --version >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "rustfmt-version",
		"command": "rustfmt --version >/dev/null 2>&1",
		"severity": "fatal"
	},
	{
		"id": "cargo-clippy-version",
		"command": "cargo clippy --version >/dev/null 2>&1",
		"severity": "fatal"
	}
]
}
