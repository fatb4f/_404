# generated domain runtime metadata: 0-interactive-shell
# shellcheck shell=sh

DOMAIN_ID='0-interactive-shell'
DOMAIN_NS='INTERACTIVE_SHELL'
DOMAIN_STAGE='interactive-shell'
DOMAIN_RING='substrate'
DOMAIN_PROVIDER='domain_local'
DOMAIN_PRIMARY_BIN=''
DOMAIN_BINS=''
DOMAIN_HOST_PACKAGE=''
DOMAIN_HOST_PACKAGES=''
DOMAIN_HOST_PACKAGE_ARCH=''
DOMAIN_HOST_PACKAGES_ARCH=''
DOMAIN_HOST_PACKAGE_DEBIAN=''
DOMAIN_HOST_PACKAGES_DEBIAN=''
DOMAIN_NPM_PACKAGE=''
DOMAIN_CARGO_CRATE=''
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/init/interactive-shell'

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
case $TOOL_PATH_HOME in
  */bin) ;;
  *) TOOL_PATH_HOME=$HOME/.local/bin; TOOL_PREFIX_HOME=${TOOL_PATH_HOME%/bin} ;;
esac

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/0-interactive-shell}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/0-interactive-shell}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/0-interactive-shell}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/0-interactive-shell/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/0-interactive-shell/share}"

DOMAIN_REQUIRES_READY='00-shell'

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644
files/zshenv|$DOTS_HOME/.zshenv|0644
files/zshrc|$DOTS_HOME/.zshrc|0644'
DOMAIN_COPIES=''
DOMAIN_LINKS=''
DOMAIN_CHECKS='zsh-available|command -v zsh >/dev/null 2>&1|fatal
zshenv-parse|test -f $DOTS_HOME/.zshenv && sh -n $DOTS_HOME/.zshenv|fatal
zshrc-parse|test -f $DOTS_HOME/.zshrc && sh -n $DOTS_HOME/.zshrc|fatal
stage-ready|test -f $XDG_STATE_HOME/_404/bootstrap/interactive-shell.ready|degraded'
