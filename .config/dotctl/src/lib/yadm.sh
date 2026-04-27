# shellcheck shell=bash

dotctl_yadm_status() {
  yadm status --short --branch
}

dotctl_yadm_bootstrap() {
  yadm bootstrap
}
