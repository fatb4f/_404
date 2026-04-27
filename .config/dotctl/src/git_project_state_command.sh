#!/usr/bin/env bash
set -euo pipefail
source "$XDG_CONFIG_HOME/dotctl/src/lib/env.sh"
source "$XDG_CONFIG_HOME/dotctl/src/lib/git.sh"
dotctl_git_project_state "${args[--input]}"
