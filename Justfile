set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

load_env := '. "$HOME/.config/shell/load-env.sh"'

default:
    just --list

check:
    dotctl check

check-shell:
    {{load_env}}; "$HOME/.config/shell/validate-env.sh"

check-tier0:
    bash "$HOME/.config/shell/tier0-check.sh"

lint-shell:
    bash "$HOME/.config/shell/lint-shell.sh"

precommit-lint:
    {{load_env}}; mkdir -p "$XDG_DATA_HOME/dotctl/policy" "$XDG_STATE_HOME/shell"
    {{load_env}}; cue eval "$HOME/.config/shell/policy/lint"/*.cue > "$XDG_DATA_HOME/dotctl/policy/shell-lint.cue"
    {{load_env}}; bash "$HOME/.config/shell/lint-shell.sh" --json > "$XDG_STATE_HOME/shell/precommit-lint.json"
    {{load_env}}; cue vet "$XDG_DATA_HOME/dotctl/policy/shell-lint.cue" "$XDG_STATE_HOME/shell/precommit-lint.json" -d '#ShellLintGate'
    {{load_env}}; dotctl check

precommit:
    just precommit-lint

check-bootstrap:
    {{load_env}}; bash -n "$HOME/.config/yadm/bootstrap"
    {{load_env}}; for f in "$HOME"/.config/yadm/bootstrap.d/*.sh; do bash -n "$f"; done
    {{load_env}}; DRY_RUN=1 HOST_CLASS="${HOST_CLASS:-debian-base}" "$HOME/.config/yadm/bootstrap"

bootstrap:
    dotctl bootstrap

bootstrap-git:
    "$HOME/.config/dotfiles-provision/bootstrap-git.sh"

audit:
    dotctl audit run

provision:
    dotctl provision

status:
    dotctl status

push:
    dotctl check
    {{load_env}}; yadm push origin main
