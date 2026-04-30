# generated domain runtime metadata: go
# shellcheck shell=sh

DOMAIN_ID='go'
DOMAIN_NS='GO'
DOMAIN_STAGE='40-tools'
DOMAIN_RING='workflow'
DOMAIN_PROVIDER='host_pkg'
DOMAIN_PRIMARY_BIN='go'
DOMAIN_HOST_PACKAGE='go'
DOMAIN_NPM_PACKAGE=''
DOMAIN_CARGO_CRATE=''
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/tools/go'

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$XDG_DATA_HOME/_404/dots}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"
: "${TOOL_PREFIX_HOME:=${TOOL_PATH_HOME%/bin}}"
[ "$TOOL_PREFIX_HOME" != "$TOOL_PATH_HOME" ] || TOOL_PREFIX_HOME=$(dirname "$TOOL_PATH_HOME")

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/go}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/go}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/go}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/go/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/go/share}"

export DOTS_REPO DOTS_DIR DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME
export DOMAIN_PREFIX DOMAIN_STATE DOMAIN_CACHE DOMAIN_BIN_HOME DOMAIN_SHARE_HOME

DOMAIN_REQUIRES_READY=''

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644'
DOMAIN_COPIES=''
DOMAIN_LINKS=''
DOMAIN_CHECKS='go-available|command -v go >/dev/null 2>&1|fatal
gofmt-available|command -v gofmt >/dev/null 2>&1|fatal
go-env-probe|go env GOPATH GOBIN GOMODCACHE >/dev/null 2>&1|fatal'
