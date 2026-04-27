set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

load_env := '. "$HOME/.config/shell/load-env.sh"'

default:
    just --list

check:
    dotctl check

check-shell:
    {{load_env}}; "$HOME/.config/shell/validate-env.sh"

check-bootstrap:
    {{load_env}}; bash -n "$HOME/.config/yadm/bootstrap"
    {{load_env}}; for f in "$HOME"/.config/yadm/bootstrap.d/*.sh; do bash -n "$f"; done
    {{load_env}}; DRY_RUN=1 HOST_CLASS="${HOST_CLASS:-debian-base}" "$HOME/.config/yadm/bootstrap"

bootstrap:
    dotctl bootstrap

audit:
    dotctl audit run

provision:
    dotctl provision

status:
    dotctl status

push:
    dotctl check
    {{load_env}}; yadm push origin main
