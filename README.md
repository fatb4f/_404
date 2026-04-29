# codex-v0-example

Surgical v0 with an activated root prefix and ordered load stages.

The current sequencing is:

1. `0-noninteractive-shell` establishes the bootstrap shell substrate.
2. `0-interactive-shell` installs the interactive shell entrypoints after the
   bootstrap shell is healthy.
3. `1-terminal` activates kitty and terminal-facing wrappers once shell handoff
   markers are present.
4. `2-agent` layers post-init agent/task helpers on top of the stable shell.
5. A future git-root init can orchestrate the nested process once the stage
   contracts are stable enough to collapse upward.

The repository already models this as domain-local installers:

- `0-noninteractive-shell/install.sh`: stage 0 shell bootstrap under `00-shell/`.
- `0-interactive-shell/install.sh`: live shell entrypoints only.
- `1-terminal/install.sh`: stage 1 terminal init under `10-terminal/`.
- `2-agent/install.sh`: stage 2 agent/task layer under `20-agent/`.
- `doctor.sh`: final read-only verification after install.
- `catalogue/install.manifest`: legacy reference manifest; the active installer
  now dispatches to domain-local install scripts.
- `<domain>/domain.cue`: declarative ownership/capability/check contract.
- `<domain>/files/`: source artifacts to activate or stage.
- `<domain>/check.sh`: readonly probe that emits one JSON object.
- `<domain>/tests/`: domain-local regression fixtures.

Runtime state/cache/runtime directories are declared in CUE. The activated tree is
rooted at `$XDG_DATA_HOME/codex/releases/<activation-id>/` and exposed through
`$XDG_DATA_HOME/codex/current`.
