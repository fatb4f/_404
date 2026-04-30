# generated domain runtime metadata: 0-noninteractive-shell
# shellcheck shell=sh

DOMAIN_ID='0-noninteractive-shell'
DOMAIN_NS='NONINTERACTIVE_SHELL'
DOMAIN_STAGE='00-shell'
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
DOMAIN_OUTPUT_DIR='generated/init/noninteractive-shell'

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

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/0-noninteractive-shell}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/0-noninteractive-shell}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/0-noninteractive-shell}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/0-noninteractive-shell/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/0-noninteractive-shell/share}"

DOMAIN_REQUIRES_READY=''

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644
files/env-loader.sh|$XDG_CONFIG_HOME/_404/env.sh|0644
files/init/loader.sh|$DOTS_HOME/.config/init/loader.sh|0644
files/init/check.sh|$DOTS_HOME/.config/init/check.sh|0644
files/init/env.sh|$DOTS_HOME/.config/init/env.sh|0644
files/init/path.sh|$DOTS_HOME/.config/init/path.sh|0644
files/bash_profile|$DOTS_HOME/.bash_profile|0644
files/bashrc|$DOTS_HOME/.bashrc|0644
files/bash_env|$DOTS_HOME/.bash_env|0644
files/profile|$DOTS_HOME/.profile|0644
files/path.sh|$DOMAIN_PREFIX/path.sh|0644
files/require.sh|$DOMAIN_PREFIX/require.sh|0644'
DOMAIN_COPIES=''
DOMAIN_LINKS=''
DOMAIN_CHECKS='stage-ready|test -f $XDG_STATE_HOME/_404/bootstrap/00-shell.ready|fatal
files-present|test -f $DOMAIN_PREFIX/init.sh && test -f $DOMAIN_PREFIX/env.sh && test -f $DOMAIN_PREFIX/path.sh && test -f $DOMAIN_PREFIX/require.sh && test -f $XDG_CONFIG_HOME/_404/env.sh && test -f $DOTS_HOME/.config/init/loader.sh && test -f $DOTS_HOME/.config/init/check.sh && test -f $DOTS_HOME/.config/init/env.sh && test -f $DOTS_HOME/.config/init/path.sh && test -f $DOTS_HOME/.bash_profile && test -f $DOTS_HOME/.bashrc && test -f $DOTS_HOME/.bash_env && test -f $DOTS_HOME/.profile|fatal
shell-parse|sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/path.sh $DOMAIN_PREFIX/require.sh $XDG_CONFIG_HOME/_404/env.sh $DOTS_HOME/.config/init/loader.sh $DOTS_HOME/.config/init/check.sh $DOTS_HOME/.config/init/env.sh $DOTS_HOME/.config/init/path.sh $DOTS_HOME/.bash_profile $DOTS_HOME/.bashrc $DOTS_HOME/.bash_env $DOTS_HOME/.profile|fatal
bash-available|command -v bash >/dev/null 2>&1|fatal
env-loader-parse|test -f $XDG_CONFIG_HOME/_404/env.sh && sh -n $XDG_CONFIG_HOME/_404/env.sh|fatal
bash_profile-parse|test -f $DOTS_HOME/.bash_profile && sh -n $DOTS_HOME/.bash_profile|fatal
bashrc-parse|test -f $DOTS_HOME/.bashrc && sh -n $DOTS_HOME/.bashrc|fatal
bash_env-parse|test -f $DOTS_HOME/.bash_env && sh -n $DOTS_HOME/.bash_env|fatal
profile-parse|test -f $DOTS_HOME/.profile && sh -n $DOTS_HOME/.profile|fatal
init-loader-parse|test -f $DOTS_HOME/.config/init/loader.sh && sh -n $DOTS_HOME/.config/init/loader.sh && test -f $DOTS_HOME/.config/init/check.sh && sh -n $DOTS_HOME/.config/init/check.sh && test -f $DOTS_HOME/.config/init/env.sh && sh -n $DOTS_HOME/.config/init/env.sh && test -f $DOTS_HOME/.config/init/path.sh && sh -n $DOTS_HOME/.config/init/path.sh|fatal'
