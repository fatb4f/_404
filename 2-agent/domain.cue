package agent

import "stage.local/policy/schema"

domain: schema.#Domain & {
	id:   "agent"
	ring: "workflow"

	owns: config: [
		{
			id:         "agent-init"
			class:      "config"
			source:     "2-agent/files/init.sh"
			target:     "$CODEX_AGENT_PREFIX/20-agent/init.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "workflow"
		},
		{
			id:         "agent-env"
			class:      "config"
			source:     "2-agent/files/env.sh"
			target:     "$CODEX_AGENT_PREFIX/20-agent/env.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "workflow"
		},
		{
			id:         "agent-functions"
			class:      "config"
			source:     "2-agent/files/functions.sh"
			target:     "$CODEX_AGENT_PREFIX/20-agent/functions.sh"
			mode:       "0644"
			activation: "atomic-copy"
			generated:  true
			ring:       "workflow"
		},
		{
			id:         "shell-tool"
			class:      "config"
			source:     "2-agent/files/bin/shell_tool"
			target:     "$CODEX_AGENT_PREFIX/20-agent/bin/shell_tool"
			mode:       "0755"
			activation: "atomic-copy"
			generated:  true
			ring:       "workflow"
		},
		{
			id:         "shell-snapshot"
			class:      "config"
			source:     "2-agent/files/bin/shell_snapshot"
			target:     "$CODEX_AGENT_PREFIX/20-agent/bin/shell_snapshot"
			mode:       "0755"
			activation: "atomic-copy"
			generated:  true
			ring:       "workflow"
		},
	]

	owns: state: [{
		id:         "agent-state"
		class:      "state"
		target:     "$XDG_STATE_HOME/codex/agent"
		activation: "none"
		ring:       "workflow"
	}]

	provides: [
		"agent.npm",
		"agent.loadable",
		"agent.shell-tool",
		"agent.shell-snapshot",
		"agent.codex",
		"agent.ready",
	]

	checks: [
		{
			id:       "agent-npm"
			command:  "command -v npm >/dev/null 2>&1"
			severity: "degraded"
			provides: ["agent.npm"]
		},
		{
			id:       "agent-codex"
			command:  "command -v codex >/dev/null 2>&1"
			severity: "degraded"
			provides: ["agent.codex"]
		},
		{
			id:       "agent-load-order"
			command:  "test -f ${CODEX_AGENT_PREFIX:?}/20-agent/init.sh && test -f ${CODEX_AGENT_PREFIX:?}/20-agent/functions.sh && grep -q 'bootstrap/20-agent.ready' ${CODEX_AGENT_PREFIX:?}/20-agent/init.sh"
			severity: "degraded"
			provides: ["agent.loadable"]
		},
		{
			id:       "agent-shell-tool"
			command:  "test -x ${CODEX_AGENT_PREFIX:?}/20-agent/bin/shell_tool"
			severity: "degraded"
			provides: ["agent.shell-tool"]
		},
		{
			id:       "agent-stage-ready"
			command:  "test -f ${XDG_STATE_HOME:-$HOME/.local/state}/codex/bootstrap/20-agent.ready"
			severity: "degraded"
			provides: ["agent.ready"]
		},
	]
}
