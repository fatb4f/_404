# Bootstrap / Dotfiles Layout

This repo is staged as two worktrees with one shared Git history:

- `~/.local/opt/_404` - the full dotfiles worktree
- `~/.local/opt/_404-bootstrap` - the sparse bootstrap worktree

The intent is to keep machine bring-up separate from tracked `$HOME` state while still sharing one repository.

## Direction

The current architecture is:

1. `bootstrap zsh`
   - establish the shell environment needed to run the rest of the bootstrap

2. `bootstrap pkgs`
   - install system packages from `artifacts-deps.json`

3. `bootstrap user-pkgs`
   - install release artifacts from `artifacts.json`
   - this includes tools such as `yadm` and `pass`

4. `bootstrap dotfiles`
   - hand off to `yadm`
   - manage direct `$HOME` config from the dotfiles worktree

## Repository Roles

- `bootstrap` owns machine setup, package installation, and first-run provisioning.
- `dotfiles` owns tracked user state under `$HOME`.
- The dependency direction is one-way: bootstrap enables dotfiles, not the other way around.

## Scope Notes

- `debian-base` is anchored on Debian Trixie and DEB822 sources.
- `arch-base` can be validated in `distrobox` before the real Arch install exists.
- `penguin` is treated as Debian Trixie plus ChromeOS VM integration.
- `archinstall` is useful for first-install on Arch, but it is not the steady-state bootstrap layer.

## Worktree Layout

The bootstrap worktree is intentionally sparse. It keeps the files needed for system bring-up and userland staging:

- `artifacts.json`
- `artifacts-deps.json`
- shell environment files
- `dot_local/bin`

The full worktree keeps the broader dotfiles surface, including desktop and application config.
