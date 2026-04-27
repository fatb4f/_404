export GDRIVE="${GDRIVE:-/mnt/chromeos/GoogleDrive/MyDrive}"
export PRJROOT="${PRJROOT:-$HOME/src}"

export DIRS=""

dirs_prepend() {
  case ":$DIRS:" in
    *":$1:"*) ;;
    *) DIRS="$1${DIRS:+:$DIRS}" ;;
  esac
}

export DIR_SRC="${DIR_SRC:-$HOME/src}"
dirs_prepend "$DIR_SRC"

export DIR_WORK="${DIR_WORK:-$DIR_SRC/workbench}"
dirs_prepend "$DIR_WORK"

export DIR_WIKI="${DIR_WIKI:-$DIR_SRC/knowledge/10-areas}"
dirs_prepend "$DIR_WIKI"

export DIR_DOTS="${DIR_DOTS:-$HOME}"
dirs_prepend "$DIR_DOTS"

export DIR_BOOTSTRAP="${DIR_BOOTSTRAP:-${XDG_DATA_HOME:-$HOME/.local/share}/src/bootstrap}"
dirs_prepend "$DIR_BOOTSTRAP"

if [ -n "${ZSH_VERSION-}" ]; then
  hash -d src="$DIR_SRC"
  hash -d work="$DIR_WORK"
  hash -d wiki="$DIR_WIKI"
  hash -d dots="$DIR_DOTS"
  hash -d strap="$DIR_BOOTSTRAP"
fi
