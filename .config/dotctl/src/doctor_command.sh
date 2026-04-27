#!/usr/bin/env bash
set -euo pipefail
source "$XDG_CONFIG_HOME/dotctl/src/lib/env.sh"
source "$DOTCTL_CONFIG_HOME/src/lib/doctor.sh"
dotctl_doctor_run "${args[--json]:-false}"
