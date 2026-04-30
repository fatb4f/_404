# generated domain runtime metadata: 0-noninteractive-shell
# shellcheck shell=sh

DOMAIN_ID='0-noninteractive-shell'
DOMAIN_NS='NONINTERACTIVE_SHELL'
DOMAIN_STAGE='00-shell'
DOMAIN_RING='substrate'
DOMAIN_PROVIDER='domain_local'
DOMAIN_PRIMARY_BIN=''
DOMAIN_HOST_PACKAGE=''
DOMAIN_NPM_PACKAGE=''
DOMAIN_CARGO_CRATE=''
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/init/noninteractive-shell'

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

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/0-noninteractive-shell}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/0-noninteractive-shell}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/0-noninteractive-shell}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/0-noninteractive-shell/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/0-noninteractive-shell/share}"

export DOTS_REPO DOTS_DIR DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME TOOL_PREFIX_HOME
export DOMAIN_PREFIX DOMAIN_STATE DOMAIN_CACHE DOMAIN_BIN_HOME DOMAIN_SHARE_HOME

DOMAIN_REQUIRES_READY=''

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644
files/env-loader.sh|$XDG_CONFIG_HOME/_404/env.sh|0644
files/bash_profile|$HOME/.bash_profile|0644
files/bashrc|$HOME/.bashrc|0644
files/path.sh|$DOMAIN_PREFIX/path.sh|0644
files/require.sh|$DOMAIN_PREFIX/require.sh|0644'
DOMAIN_LINKS=''
DOMAIN_CHECKS='stage-ready|test -f $XDG_STATE_HOME/_404/bootstrap/00-shell.ready|fatal
files-present|test -f $DOMAIN_PREFIX/init.sh && test -f $DOMAIN_PREFIX/env.sh && test -f $DOMAIN_PREFIX/path.sh && test -f $DOMAIN_PREFIX/require.sh && test -f $XDG_CONFIG_HOME/_404/env.sh && test -f $HOME/.bash_profile && test -f $HOME/.bashrc|fatal
shell-parse|sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/path.sh $DOMAIN_PREFIX/require.sh $XDG_CONFIG_HOME/_404/env.sh $HOME/.bash_profile $HOME/.bashrc|fatal
bash-available|command -v bash >/dev/null 2>&1|fatal
env-loader-parse|test -f $XDG_CONFIG_HOME/_404/env.sh && sh -n $XDG_CONFIG_HOME/_404/env.sh|fatal
bash_profile-parse|test -f $HOME/.bash_profile && sh -n $HOME/.bash_profile|fatal
bashrc-parse|test -f $HOME/.bashrc && sh -n $HOME/.bashrc|fatal'
