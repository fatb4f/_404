package domains

import "stage.local/src/schema"

// CUE authority mirror for src/domains/seed.json.
// Bootstrap consumes seed.json so this repo can regenerate before CUE itself
// is installed. Once CUE is available, export this package to JSON and replace
// src/domains/seed.json.

roots: schema.#Roots & {
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

// Keep seed.json as the bootstrap materialized form until cue export is wired.
