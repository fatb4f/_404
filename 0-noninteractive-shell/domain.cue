package noninteractive_shell

import "codex.local/schema"

domain: schema.#Domain & {
  id: "noninteractive-shell"
  ring: "bootstrap"

  owns: config: [
    {
      id: "root-init"
      class: "config"
      source: "noninteractive-shell/files/init.sh"
      target: "$CODEX_ROOT/00-shell/init.sh"
      mode: "0644"
      activation: "atomic-copy"
      generated: true
      ring: "bootstrap"
    },
    {
      id: "root-env"
      class: "config"
      source: "noninteractive-shell/files/env.sh"
      target: "$CODEX_ROOT/00-shell/env.sh"
      mode: "0644"
      activation: "atomic-copy"
      generated: true
      ring: "bootstrap"
    },
    {
      id: "root-path"
      class: "config"
      source: "noninteractive-shell/files/path.sh"
      target: "$CODEX_ROOT/00-shell/path.sh"
      mode: "0644"
      activation: "atomic-copy"
      generated: true
      ring: "bootstrap"
    },
    {
      id: "root-require"
      class: "config"
      source: "noninteractive-shell/files/require.sh"
      target: "$CODEX_ROOT/00-shell/require.sh"
      mode: "0644"
      activation: "atomic-copy"
      generated: true
      ring: "bootstrap"
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
      id: "bash-parse"
      command: "bash -n noninteractive-shell/files/init.sh noninteractive-shell/files/env.sh noninteractive-shell/files/path.sh noninteractive-shell/files/require.sh && grep -q 'bootstrap/00-shell.ready' noninteractive-shell/files/init.sh"
      severity: "fatal"
      provides: ["shell.noninteractive.parse-valid"]
    },
    {
      id: "root-prefix-present"
      command: "test -f ${CODEX_ROOT:?}/00-shell/init.sh && test -f ${CODEX_ROOT:?}/00-shell/require.sh"
      severity: "degraded"
      provides: ["shell.noninteractive.root-prefix"]
    },
    {
      id: "root-stage-ready"
      command: "test -f ${XDG_STATE_HOME:-$HOME/.local/state}/codex/bootstrap/00-shell.ready"
      severity: "degraded"
      provides: ["shell.bootstrap.ready"]
    },
  ]
}
