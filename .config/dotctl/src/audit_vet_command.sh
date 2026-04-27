#!/usr/bin/env bash
set -euo pipefail

source "$XDG_CONFIG_HOME/dotctl/src/lib/env.sh"
source "$DOTCTL_CONFIG_HOME/src/lib/audit.sh"

dotctl_audit_vet "${args[audit_json]}"
