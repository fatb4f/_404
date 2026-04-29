package terminal

import "stage.local/policy/schema"

domain: schema.#Domain & {
	id:   "terminal"
	ring: "bootstrap"

	owns: config: [{
		id:         "terminal-init"
		class:      "config"
		source:     "1-terminal/files/init.sh"
		target:     "$STAGE_ROOT/10-terminal/init.sh"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "bootstrap"
	}, {
		id:         "terminal-env"
		class:      "config"
		source:     "1-terminal/files/env.sh"
		target:     "$STAGE_ROOT/10-terminal/env.sh"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "bootstrap"
	}, {
		id:         "terminal-functions"
		class:      "config"
		source:     "1-terminal/files/functions.sh"
		target:     "$STAGE_ROOT/10-terminal/functions.sh"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "bootstrap"
	}, {
		id:         "kitty-conf"
		class:      "config"
		source:     "1-terminal/files/kitty.conf"
		target:     "$STAGE_ROOT/10-terminal/kitty/kitty.conf"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "bootstrap"
	}, {
		id:         "kitty-overrides"
		class:      "config"
		source:     "1-terminal/files/overrides.kitty.conf"
		target:     "$STAGE_ROOT/10-terminal/kitty/overrides.kitty.conf"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "workflow"
	}, {
		id:         "kitty-t0"
		class:      "config"
		source:     "1-terminal/files/bin/kitty-t0"
		target:     "$STAGE_ROOT/10-terminal/bin/kitty-t0"
		mode:       "0755"
		activation: "atomic-copy"
		generated:  true
		ring:       "workflow"
	}, {
		id:         "kitty-launch-with-cwd"
		class:      "config"
		source:     "1-terminal/files/bin/kitty-launch-with-cwd"
		target:     "$STAGE_ROOT/10-terminal/bin/kitty-launch-with-cwd"
		mode:       "0755"
		activation: "atomic-copy"
		generated:  true
		ring:       "workflow"
	}, {
		id:         "kitty-launch-desktop"
		class:      "config"
		source:     "1-terminal/files/bin/kitty-launch-desktop"
		target:     "$STAGE_ROOT/10-terminal/bin/kitty-launch-desktop"
		mode:       "0755"
		activation: "atomic-copy"
		generated:  true
		ring:       "workflow"
	}, {
		id:         "kitty-desktop"
		class:      "config"
		source:     "1-terminal/files/applications/stage-kitty.desktop"
		target:     "$STAGE_ROOT/10-terminal/applications/stage-kitty.desktop"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "workflow"
	}, {
		id:         "kitty-workflow-desktop"
		class:      "config"
		source:     "1-terminal/files/applications/stage-kitty-workflow.desktop"
		target:     "$STAGE_ROOT/10-terminal/applications/stage-kitty-workflow.desktop"
		mode:       "0644"
		activation: "atomic-copy"
		generated:  true
		ring:       "workflow"
	}]

	provides: [
		"terminal.config.valid",
		"terminal.launchable",
		"terminal.load-order",
		"terminal.ready",
	]

	checks: [
		{
			id:       "kitty-config-present"
			command:  "test -f ${STAGE_ROOT:?}/10-terminal/kitty/kitty.conf"
			severity: "degraded"
			provides: ["terminal.config.valid"]
		},
		{
			id:       "terminal-load-order"
			command:  "test -f ${STAGE_ROOT:?}/10-terminal/init.sh && test -f ${STAGE_ROOT:?}/10-terminal/env.sh && test -f ${STAGE_ROOT:?}/10-terminal/functions.sh && grep -q 'bootstrap/10-terminal.ready' ${STAGE_ROOT:?}/10-terminal/init.sh"
			severity: "degraded"
			provides: ["terminal.load-order"]
		},
		{
			id:       "terminal-stage-ready"
			command:  "test -f ${XDG_STATE_HOME:-$HOME/.local/state}/_404/bootstrap/10-terminal.ready"
			severity: "degraded"
			provides: ["terminal.ready"]
		},
	]
}
