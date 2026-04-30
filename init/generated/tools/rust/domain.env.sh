# generated domain runtime metadata: rust
# shellcheck shell=sh

DOMAIN_ID='rust'
DOMAIN_NS='RUST'
DOMAIN_STAGE='42-rust'
DOMAIN_RING='workflow'
DOMAIN_PROVIDER='host_pkg'
DOMAIN_PRIMARY_BIN='rustc'
DOMAIN_BINS='rustc cargo rustfmt clippy-driver'
DOMAIN_HOST_PACKAGE='rustc'
DOMAIN_HOST_PACKAGES='rustc cargo rustfmt rust-clippy'
DOMAIN_HOST_PACKAGE_ARCH='rust'
DOMAIN_HOST_PACKAGES_ARCH='rust'
DOMAIN_HOST_PACKAGE_DEBIAN='rustc'
DOMAIN_HOST_PACKAGES_DEBIAN='rustc cargo rustfmt rust-clippy'
DOMAIN_NPM_PACKAGE=''
DOMAIN_CARGO_CRATE=''
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/tools/rust'

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

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/rust}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/rust}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/rust}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/rust/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/rust/share}"

DOMAIN_REQUIRES_READY=''

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644'
DOMAIN_COPIES=''
DOMAIN_LINKS=''
DOMAIN_CHECKS='rustc-available|command -v rustc >/dev/null 2>&1|fatal
cargo-available|command -v cargo >/dev/null 2>&1|fatal
rustfmt-available|command -v rustfmt >/dev/null 2>&1|fatal
clippy-driver-available|command -v clippy-driver >/dev/null 2>&1|fatal
rustc-version|rustc --version >/dev/null 2>&1|fatal
cargo-version|cargo --version >/dev/null 2>&1|fatal
rustfmt-version|rustfmt --version >/dev/null 2>&1|fatal
cargo-clippy-version|cargo clippy --version >/dev/null 2>&1|fatal'
