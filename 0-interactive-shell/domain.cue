package interactive_shell

import "codex.local/schema"

domain: schema.#Domain & {
  id: "interactive-shell"
  ring: "rescue"

  owns: config: [
    {
      id: "zshenv"
      class: "config"
      source: "interactive-shell/files/zshenv"
      target: "$HOME/.zshenv"
      mode: "0644"
      activation: "atomic-copy"
      userEditable: false
      generated: false
      ring: "rescue"
    },
    {
      id: "zshrc"
      class: "config"
      source: "interactive-shell/files/zshrc"
      target: "$HOME/.zshrc"
      mode: "0644"
      activation: "atomic-copy"
      userEditable: false
      generated: false
      ring: "bootstrap"
    },
  ]

  owns: state: [{
    id: "interactive-shell-state"
    class: "state"
    target: "$XDG_STATE_HOME/codex/interactive-shell"
    activation: "none"
    ring: "bootstrap"
  }]

  owns: cache: [{
    id: "zsh-cache"
    class: "cache"
    target: "$XDG_CACHE_HOME/zsh"
    activation: "none"
    ring: "workflow"
  }]

  provides: [
    "shell.interactive.minimal",
    "shell.interactive.loadable",
    "shell.interactive.load-order",
    "shell.interactive.ready",
  ]

  checks: [
    {
      id: "zshenv-parse"
      command: "zsh -n $HOME/.zshenv && grep -q 'bootstrap/00-shell.ready' $HOME/.zshenv"
      severity: "fatal"
      provides: ["shell.interactive.minimal"]
    },
    {
      id: "zsh-interactive-load"
      command: "zsh -i -c exit"
      severity: "degraded"
      provides: ["shell.interactive.loadable"]
    },
    {
      id: "zsh-load-order"
      command: "grep -q 'bootstrap/00-shell.ready' $HOME/.zshenv && grep -q 'CODEX_ROOT/00-shell/init.sh' $HOME/.zshenv && grep -q 'bootstrap/10-terminal.ready' $HOME/.zshrc && grep -q 'CODEX_ROOT/10-terminal/init.sh' $HOME/.zshrc && grep -q 'CODEX_ROOT/20-agent/init.sh' $HOME/.zshrc"
      severity: "degraded"
      provides: ["shell.interactive.load-order"]
    },
    {
      id: "shell-interactive-ready"
      command: "test -f ${XDG_STATE_HOME:-$HOME/.local/state}/codex/bootstrap/interactive-shell.ready"
      severity: "degraded"
      provides: ["shell.interactive.ready"]
    },
  ]
}
