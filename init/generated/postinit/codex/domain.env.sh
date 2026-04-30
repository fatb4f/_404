# generated domain runtime metadata: 2-agent
# shellcheck shell=sh

DOMAIN_ID='2-agent'
DOMAIN_NS='AGENT'
DOMAIN_STAGE='20-agent'
DOMAIN_RING='agent'
DOMAIN_PROVIDER='npm_global'
DOMAIN_PRIMARY_BIN='codex'
DOMAIN_HOST_PACKAGE=''
DOMAIN_NPM_PACKAGE='@openai/codex'
DOMAIN_CARGO_CRATE=''
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/postinit/codex'

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_DATA_HOME:=$DOTS_HOME/.local/share}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${TOOL_PREFIX_HOME:=${TOOL_PATH_HOME%/bin}}"
[ "$TOOL_PREFIX_HOME" != "$TOOL_PATH_HOME" ] || TOOL_PREFIX_HOME=$(dirname "$TOOL_PATH_HOME")

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/2-agent}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/2-agent}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/2-agent}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/2-agent/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/2-agent/share}"

export DOTS_REPO DOTS_DIR DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME
export DOMAIN_PREFIX DOMAIN_STATE DOMAIN_CACHE DOMAIN_BIN_HOME DOMAIN_SHARE_HOME

DOMAIN_REQUIRES_READY='10-terminal'

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644
files/functions.sh|$DOMAIN_PREFIX/functions.sh|0644
files/bin/shell_tool|$DOMAIN_PREFIX/bin/shell_tool|0755
files/bin/shell_snapshot|$DOMAIN_PREFIX/bin/shell_snapshot|0755'
DOMAIN_LINKS='$DOMAIN_PREFIX/bin/shell_tool|$TOOL_PATH_HOME/shell_tool
$DOMAIN_PREFIX/bin/shell_snapshot|$TOOL_PATH_HOME/shell_snapshot'
DOMAIN_CHECKS='stage-ready|test -f $XDG_STATE_HOME/_404/bootstrap/20-agent.ready|degraded
npm-available|command -v npm >/dev/null 2>&1|fatal
codex-available|command -v codex >/dev/null 2>&1|degraded
files-present|test -x $DOMAIN_PREFIX/bin/shell_tool && test -x $DOMAIN_PREFIX/bin/shell_snapshot|fatal
shell-parse|sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/functions.sh|fatal'
