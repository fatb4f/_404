# shellcheck shell=bash

source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/handler/yadm.sh"

dotctl_yadm_status() {
  dotctl_yadm_handler status --short --branch
}

dotctl_yadm_bootstrap() {
  dotctl_yadm_handler bootstrap
}
