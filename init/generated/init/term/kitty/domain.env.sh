# generated domain runtime metadata: generated/init/term/kitty
# shellcheck shell=sh

DOMAIN_ID='generated/init/term/kitty'
DOMAIN_NS='TERMINAL'
DOMAIN_STAGE='10-terminal'
DOMAIN_RING='terminal'
DOMAIN_PROVIDER='host_pkg'
DOMAIN_PRIMARY_BIN='kitty'
DOMAIN_HOST_PACKAGE='kitty'
DOMAIN_NPM_PACKAGE=''
DOMAIN_CARGO_CRATE=''
DOMAIN_GO_MODULE=''
DOMAIN_OUTPUT_DIR='generated/init/term/kitty'

: "${DOTS_REPO:=src}"
: "${DOTS_DIR:=dots}"
: "${DOTS_HOME:=$HOME/$DOTS_REPO/$DOTS_DIR}"
: "${XDG_CONFIG_HOME:=$DOTS_HOME/.config}"
: "${XDG_DATA_HOME:=$DOTS_HOME/.local/share}"
: "${XDG_OPT_HOME:=$DOTS_HOME/.local/opt}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${TOOL_PATH_HOME:=$HOME/.local/bin}"

: "${DOMAIN_PREFIX:=$XDG_OPT_HOME/1-terminal}"
: "${DOMAIN_STATE:=$XDG_STATE_HOME/_404/1-terminal}"
: "${DOMAIN_CACHE:=$XDG_CACHE_HOME/_404/1-terminal}"
: "${DOMAIN_BIN_HOME:=$XDG_OPT_HOME/1-terminal/bin}"
: "${DOMAIN_SHARE_HOME:=$XDG_OPT_HOME/1-terminal/share}"

export DOTS_REPO DOTS_DIR DOTS_HOME XDG_CONFIG_HOME XDG_DATA_HOME XDG_OPT_HOME XDG_STATE_HOME XDG_CACHE_HOME TOOL_PATH_HOME
export DOMAIN_PREFIX DOMAIN_STATE DOMAIN_CACHE DOMAIN_BIN_HOME DOMAIN_SHARE_HOME

DOMAIN_REQUIRES_READY='00-shell interactive-shell'

DOMAIN_FILES='files/env.sh|$DOMAIN_PREFIX/env.sh|0644
files/init.sh|$DOMAIN_PREFIX/init.sh|0644
files/functions.sh|$DOMAIN_PREFIX/functions.sh|0644
files/kitty.conf|$DOMAIN_PREFIX/kitty/kitty.conf|0644
files/overrides.kitty.conf|$DOMAIN_PREFIX/kitty/overrides.kitty.conf|0644
files/bin/kitty-t0|$DOMAIN_PREFIX/bin/kitty-t0|0755
files/bin/kitty-launch-with-cwd|$DOMAIN_PREFIX/bin/kitty-launch-with-cwd|0755
files/bin/kitty-launch-desktop|$DOMAIN_PREFIX/bin/kitty-launch-desktop|0755
files/applications/stage-kitty.desktop|$DOMAIN_PREFIX/applications/stage-kitty.desktop|0644
files/applications/stage-kitty-workflow.desktop|$DOMAIN_PREFIX/applications/stage-kitty-workflow.desktop|0644'
DOMAIN_LINKS='$DOMAIN_PREFIX/kitty/kitty.conf|$XDG_CONFIG_HOME/kitty/kitty.conf
$DOMAIN_PREFIX/kitty/overrides.kitty.conf|$XDG_CONFIG_HOME/kitty/overrides.kitty.conf
$DOMAIN_PREFIX/bin/kitty-t0|$TOOL_PATH_HOME/kitty-t0
$DOMAIN_PREFIX/bin/kitty-launch-with-cwd|$TOOL_PATH_HOME/kitty-launch-with-cwd
$DOMAIN_PREFIX/bin/kitty-launch-desktop|$TOOL_PATH_HOME/kitty-launch-desktop
$DOMAIN_PREFIX/applications/stage-kitty.desktop|$XDG_DATA_HOME/applications/stage-kitty.desktop
$DOMAIN_PREFIX/applications/stage-kitty-workflow.desktop|$XDG_DATA_HOME/applications/stage-kitty-workflow.desktop'
DOMAIN_CHECKS='stage-ready|test -f $XDG_STATE_HOME/_404/bootstrap/10-terminal.ready|degraded
files-present|test -f $DOMAIN_PREFIX/kitty/kitty.conf && test -x $DOMAIN_PREFIX/bin/kitty-t0|degraded
shell-parse|sh -n $DOMAIN_PREFIX/init.sh $DOMAIN_PREFIX/env.sh $DOMAIN_PREFIX/functions.sh $DOMAIN_PREFIX/bin/kitty-launch-desktop|fatal
kitty-available|command -v kitty >/dev/null 2>&1|warning'
