#!/usr/bin/env bash
set -euo pipefail

STRAP_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)"
PROJECT_ROOT="$(CDPATH= cd -- "$STRAP_ROOT/../.." && pwd -P)"
LIB_DIR="$STRAP_ROOT/lib"
PKG_DIR="$LIB_DIR/pkgs"
USERLAND_MANIFEST="$PKG_DIR/artifacts.json"

# shellcheck source=strap/src/lib/common.sh
. "$LIB_DIR/common.sh"
# shellcheck source=strap/src/lib/arch_host.sh
. "$LIB_DIR/arch_host.sh"
# shellcheck source=strap/src/lib/debian_host.sh
. "$LIB_DIR/debian_host.sh"
# shellcheck source=strap/src/lib/bootstrap_env.sh
. "$LIB_DIR/bootstrap_env.sh"
# shellcheck source=strap/src/lib/zsh.sh
. "$LIB_DIR/zsh.sh"
# shellcheck source=strap/src/lib/system_pkgs.sh
. "$LIB_DIR/system_pkgs.sh"
# shellcheck source=strap/src/lib/userland.sh
. "$LIB_DIR/userland.sh"
# shellcheck source=strap/src/lib/dotfiles.sh
. "$LIB_DIR/dotfiles.sh"
# shellcheck source=strap/src/lib/doctor.sh
. "$LIB_DIR/doctor.sh"

usage() {
  cat <<'USAGE'
usage: strap/bootstrap [options]

Options:
  --dry-run                 Print actions without applying changes.
  --host CLASS              Override detected host class: arch-base|debian-base.
  --stages CSV              Run selected stages. Default: env,pkgs,userland,dotfiles,chsh,doctor.
                            Available: detect,env,pkgs,userland,dotfiles,chsh,doctor.
  --dotfiles-repo URL       yadm remote to clone when no yadm repo exists.
  --import-home-tree        Import ./home as a direct $HOME overlay before yadm activation.
  --force                   Reinstall userland tools even if links already exist.
  -h, --help                Show this help.

Environment:
  DOTFILES_REPO_URL         Same as --dotfiles-repo.
  _404_LOCAL_BIN            Override userland install directory. Default: ~/.local/bin.
  _404_ARTIFACT_CACHE       Override artifact download cache.
USAGE
}

DRY_RUN=${DRY_RUN:-0}
FORCE=${FORCE:-0}
IMPORT_HOME_TREE=${IMPORT_HOME_TREE:-0}
HOST_CLASS=${HOST_CLASS:-}
STAGES=${STAGES:-env,pkgs,userland,dotfiles,chsh,doctor}

while (($#)); do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --host)
      HOST_CLASS=${2:-}
      [[ -n "$HOST_CLASS" ]] || die '--host requires a value'
      shift 2
      ;;
    --stages|--stage)
      STAGES=${2:-}
      [[ -n "$STAGES" ]] || die '--stages requires a comma-separated value'
      shift 2
      ;;
    --dotfiles-repo)
      DOTFILES_REPO_URL=${2:-}
      [[ -n "$DOTFILES_REPO_URL" ]] || die '--dotfiles-repo requires a URL'
      shift 2
      ;;
    --import-home-tree)
      IMPORT_HOME_TREE=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

export DRY_RUN FORCE IMPORT_HOME_TREE DOTFILES_REPO_URL STRAP_ROOT

if [[ -z "$HOST_CLASS" ]]; then
  HOST_CLASS="$("$LIB_DIR/which_host.sh")" || die 'host detection failed'
fi

case "$HOST_CLASS" in
  arch-base|debian-base) ;;
  *) die "unsupported host class: $HOST_CLASS" ;;
esac

stage_enabled() {
  local needle=${1:?stage}
  case ",$STAGES," in
    *",$needle,"*) return 0 ;;
    *) return 1 ;;
  esac
}

info "project_root=$PROJECT_ROOT"
info "host_class=$HOST_CLASS"
info "stages=$STAGES"

if stage_enabled detect; then
  printf '%s\n' "$HOST_CLASS"
fi

if stage_enabled env; then
  bootstrap_env "$LIB_DIR/shell" "$HOME"
fi


if stage_enabled pkgs; then
  install_system_packages "$HOST_CLASS" "$PKG_DIR"
fi

if stage_enabled userland; then
  install_userland_tools "$USERLAND_MANIFEST"
fi

if stage_enabled dotfiles; then
  activate_dotfiles "$PROJECT_ROOT"
fi

if stage_enabled chsh; then
  set_login_shell_after_dotfiles
fi

if stage_enabled doctor; then
  doctor "$PROJECT_ROOT" "$HOST_CLASS"
fi
