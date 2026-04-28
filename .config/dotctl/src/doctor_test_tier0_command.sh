#!/usr/bin/env bash
set -euo pipefail

source "$XDG_CONFIG_HOME/dotctl/src/lib/env.sh"
source "$DOTCTL_CONFIG_HOME/src/lib/tier0.sh"

backend="${args[--backend]:-matrix}"
strict="${args[--strict]:-true}"
json="${args[--json]:-false}"
summary="${args[--summary]:-false}"
report_dir="${args[--report-dir]:-}"

if [[ "$summary" == true ]]; then
  json=true
fi

dotctl_tier0_run "$backend" "$strict" "$json" "$report_dir"
