# generated domain runtime metadata: ripgrep
# shellcheck shell=sh

DOMAIN_ID='ripgrep'
DOMAIN_NS='RIPGREP'
DOMAIN_STAGE='43-ripgrep'
DOMAIN_RING='workflow'
DOMAIN_PROVIDER='cargo_binstall'
DOMAIN_PRIMARY_BIN='rg'
DOMAIN_BINS='rg'
DOMAIN_HOST_PACKAGE=''
DOMAIN_HOST_PACKAGES=''
DOMAIN_HOST_PACKAGE_ARCH=''
DOMAIN_HOST_PACKAGES_ARCH=''
DOMAIN_HOST_PACKAGE_DEBIAN=''
DOMAIN_HOST_PACKAGES_DEBIAN=''
DOMAIN_NPM_PACKAGE=''
DOMAIN_CARGO_CRATE='ripgrep'
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/tools/ripgrep'

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

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/ripgrep}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/ripgrep}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/ripgrep}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/ripgrep/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/ripgrep/share}"

DOMAIN_REQUIRES_READY=''

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644'
DOMAIN_COPIES=''
DOMAIN_LINKS=''
DOMAIN_CHECKS='rg-available|command -v rg >/dev/null 2>&1|fatal
cargo-available|command -v cargo >/dev/null 2>&1|fatal
cargo-binstall-available|command -v cargo-binstall >/dev/null 2>&1|degraded
rg-version|rg --version >/dev/null 2>&1|fatal'
