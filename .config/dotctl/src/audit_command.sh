source "${XDG_CONFIG_HOME:-$HOME/.config}/dotctl/src/lib/env.sh"
source "$DOTCTL_CONFIG_HOME/src/lib/audit.sh"

dotctl_audit_run
