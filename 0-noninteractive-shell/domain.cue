package noninteractive_shell

import "stage.local/policy/schema"

domain: schema.#Domain & {
	id:   "noninteractive-shell"
	ring: "bootstrap"

	owns: config: [
		{
			id:         "root-init"
			class:      "config"
			source:     "0-noninteractive-shell/files/init.sh"
			target:     "$STAGE_ROOT/00-shell/init.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "bootstrap"
		},
		{
			id:         "root-env"
			class:      "config"
			source:     "0-noninteractive-shell/files/env.sh"
			target:     "$STAGE_ROOT/00-shell/env.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "bootstrap"
		},
		{
			id:         "root-path"
			class:      "config"
			source:     "0-noninteractive-shell/files/path.sh"
			target:     "$STAGE_ROOT/00-shell/path.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "bootstrap"
		},
		{
			id:         "root-require"
			class:      "config"
			source:     "0-noninteractive-shell/files/require.sh"
			target:     "$STAGE_ROOT/00-shell/require.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "bootstrap"
		},
	]

	provides: [
		"shell.noninteractive.parse-valid",
		"shell.noninteractive.adapter-substrate",
		"shell.noninteractive.root-prefix",
		"shell.bootstrap.ready",
	]

	checks: [
		{
			id:       "bash-parse"
			command:  "bash -n 0-noninteractive-shell/files/init.sh 0-noninteractive-shell/files/env.sh 0-noninteractive-shell/files/path.sh 0-noninteractive-shell/files/require.sh && grep -q 'bootstrap/00-shell.ready' 0-noninteractive-shell/files/init.sh"
			severity: "fatal"
			provides: ["shell.noninteractive.parse-valid"]
		},
		{
			id:       "root-prefix-present"
			command:  "test -f ${STAGE_ROOT:?}/00-shell/init.sh && test -f ${STAGE_ROOT:?}/00-shell/require.sh"
			severity: "degraded"
			provides: ["shell.noninteractive.root-prefix"]
		},
		{
			id:       "root-stage-ready"
			command:  "test -f ${XDG_STATE_HOME:-$HOME/.local/state}/_404/bootstrap/00-shell.ready"
			severity: "degraded"
			provides: ["shell.bootstrap.ready"]
		},
	]
}
