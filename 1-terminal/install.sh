#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
. "$ROOT/policy/lib/fs.sh"

: "${CODEX_ROOT:?CODEX_ROOT is required}"
: "${CODEX_DRY_RUN:=0}"

codex_stage_require_ready "00-shell"
codex_stage_require_ready "interactive-shell"

source_dir="$ROOT/1-terminal/files"
target_dir="$CODEX_ROOT/10-terminal"

terminal_kitty_release_asset_url() {
  asset_name=$1

  command -v curl >/dev/null 2>&1 || return 127
  command -v python3 >/dev/null 2>&1 || return 127

  curl -fsSL https://api.github.com/repos/kovidgoyal/kitty/releases/latest |
    python3 -c 'import json, sys
asset_name = sys.argv[1]
payload = json.load(sys.stdin)
for asset in payload.get("assets", []):
    if asset.get("name") == asset_name:
        print(asset.get("browser_download_url", ""))
        raise SystemExit(0)
raise SystemExit(1)
' "$asset_name"
}

terminal_ensure_kitty() {
  if command -v kitty >/dev/null 2>&1; then
    return 0
  fi

  if codex_install_pkg kitty; then
    return 0
  fi

  if [ "${KITTY_INSTALL_METHOD:-}" = "curl" ]; then
    asset_name="${KITTY_RELEASE_ASSET:-kitty-linux-x86_64.tar.xz}"
    asset_url=$(terminal_kitty_release_asset_url "$asset_name") || {
      printf >&2 'unable to resolve kitty release asset: %s\n' "$asset_name"
      return 127
    }
    printf 'resolved kitty asset: %s\n' "$asset_url"
    return 0
  fi

  printf >&2 'kitty not found and no package manager available\n'
  return 127
}

terminal_ensure_kitty

install_file() {
  src=$1
  dst=$2
  mode=$3

  printf 'activate %-22s %s -> %s\n' "10-terminal" "${src#$ROOT/}" "$dst"
  [ "$CODEX_DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  atomic_copy_file "$src" "$dst" "$mode"
}

install_link() {
  src=$1
  dst=$2

  printf 'activate %-22s %s -> %s\n' "10-terminal" "$src" "$dst"
  [ "$CODEX_DRY_RUN" -eq 1 ] && return 0
  mkdir -p "$(dirname "$dst")"
  ln -sfn "$src" "$dst"
}

install_file "$source_dir/kitty.conf" "$target_dir/kitty/kitty.conf" 0644
install_file "$source_dir/overrides.kitty.conf" "$target_dir/kitty/overrides.kitty.conf" 0644
install_file "$source_dir/env.sh" "$target_dir/env.sh" 0644
install_file "$source_dir/functions.sh" "$target_dir/functions.sh" 0644
install_file "$source_dir/init.sh" "$target_dir/init.sh" 0644
install_file "$source_dir/bin/kitty-t0" "$target_dir/bin/kitty-t0" 0755
install_file "$source_dir/bin/kitty-launch-with-cwd" "$target_dir/bin/kitty-launch-with-cwd" 0755
install_file "$source_dir/bin/kitty-launch-desktop" "$target_dir/bin/kitty-launch-desktop" 0755
install_file "$source_dir/applications/codex-kitty.desktop" "$target_dir/applications/codex-kitty.desktop" 0644
install_file "$source_dir/applications/codex-kitty-workflow.desktop" "$target_dir/applications/codex-kitty-workflow.desktop" 0644

install_link "$CODEX_ROOT/10-terminal/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
install_link "$CODEX_ROOT/10-terminal/kitty/overrides.kitty.conf" "$HOME/.config/kitty/overrides.kitty.conf"
install_link "$CODEX_ROOT/10-terminal/bin/kitty-t0" "$HOME/.local/bin/kitty-t0"
install_link "$CODEX_ROOT/10-terminal/bin/kitty-launch-with-cwd" "$HOME/.local/bin/kitty-launch-with-cwd"
install_link "$CODEX_ROOT/10-terminal/bin/kitty-launch-desktop" "$HOME/.local/bin/kitty-launch-desktop"
install_link "$CODEX_ROOT/10-terminal/applications/codex-kitty.desktop" "$HOME/.local/share/applications/codex-kitty.desktop"
install_link "$CODEX_ROOT/10-terminal/applications/codex-kitty-workflow.desktop" "$HOME/.local/share/applications/codex-kitty-workflow.desktop"

codex_stage_mark_ready "10-terminal"
