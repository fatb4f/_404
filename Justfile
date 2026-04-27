set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

audit_targets := ".config/bin .config/broot .config/nvim .config/uv"

load_env := '. "$HOME/.config/shell/load-env.sh"'

default:
    just --list

check:
    just check-shell
    just check-bootstrap
    just audit
    yadm status --short --branch

check-shell:
    {{load_env}}; "$HOME/.config/shell/validate-env.sh"

check-bootstrap:
    {{load_env}}; bash -n "$HOME/.config/yadm/bootstrap"
    {{load_env}}; for f in "$HOME"/.config/yadm/bootstrap.d/*.sh; do bash -n "$f"; done
    {{load_env}}; DRY_RUN=1 HOST_CLASS="${HOST_CLASS:-debian-base}" "$HOME/.config/yadm/bootstrap"

bootstrap:
    {{load_env}}; yadm bootstrap

audit:
    {{load_env}}; "$HOME/.config/dotfiles-audit/audit.sh" {{audit_targets}}

provision:
    {{load_env}}; yadm bootstrap
    just check

push:
    just check
    {{load_env}}; yadm push origin main
