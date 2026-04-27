# `_404` host bootstrap + direct-HOME dotfiles

This repository is now split by authority boundary:

```text
strap/   host bootstrap and activation adapter
home/    direct $HOME overlay for dotfile import/tracking
```

Bootstrap a new host with:

```bash
curl -fsSL https://raw.githubusercontent.com/fatb4f/_404/main/init.sh | bash
```

## Contract

```text
host-bootstrap
  owns: bash-only bootstrap runner, environment seed, system packages, userland tool install
  scope: arch-base | debian-base

userland installer
  owns: GitHub release artifacts under $HOME/.local/opt and $HOME/.local/bin
  exposes: stable symlinks under $HOME/.local/bin

dotfiles
  owns: tracked $HOME state
  manager: yadm first, bare Git possible
  source transform: none
```

## Current flow

```text
acquire repo
  -> strap/bootstrap
      -> detect host class
      -> seed shell env
      -> install system packages/deps
      -> install userland release tools
      -> activate direct-HOME dotfiles
      -> run post-dotfiles package setup
      -> optional chsh after dotfiles are live
      -> doctor
```

## Quick start

Dry-run everything:

```bash
strap/bootstrap --dry-run
```

Run only the non-invasive checks:

```bash
strap/bootstrap --dry-run --stages detect,env,doctor
```

Install host packages:

```bash
strap/bootstrap --stages pkgs
```

Install userland release tools:

```bash
strap/bootstrap --stages userland
```

Activate dotfiles with yadm:

```bash
DOTFILES_REPO_URL='git@github.com:USER/dotfiles.git' \
  strap/bootstrap --stages dotfiles,post,doctor
```

Seed this repository's `home/` overlay into `$HOME` before yadm activation:

```bash
strap/bootstrap --import-home-tree --stages dotfiles,post,doctor
```

## Direct-HOME migration status

The `home/` tree has been converted away from chezmoi source filenames:

```text
dot_*        -> .* 
executable_* -> real executable name + mode 0755
readonly_*   -> real filename
empty_*      -> real filename
```

That makes `home/` a real `$HOME` overlay rather than a chezmoi source tree.

## Bootstrap shell

Bootstrap scripts run non-interactively under `bash`.

`zsh` is a system dependency, not a bootstrap prerequisite. It is installed by the package-manager stage and becomes the login shell only after the dotfiles layer is live.

## Host classes

Only two base classes are active:

| Class | Package adapter | Notes |
|---|---|---|
| `arch-base` | `pacman` | Arch, Artix, EndeavourOS-style systems |
| `debian-base` | `apt-get` | Debian, Ubuntu, Penguin/Borealis-style systems |

ChromeOS/Penguin-specific integration should be added later as an overlay on `debian-base`.

## Important files

```text
strap/bootstrap                         entrypoint
strap/src/init.sh                       coordinator
strap/src/lib/which_host.sh             host-class detection
strap/src/lib/pkgs/arch-base.pkgs       Arch package overlay
strap/src/lib/pkgs/debian-base.pkgs     Debian package overlay
strap/src/lib/userland/tools.tsv        GitHub release userland tools
strap/contracts/*.cue                   authority contracts
home/                                   direct $HOME overlay
```

## Next cut

The next high-signal work is to harden the GitHub release installer:

1. add checksums/attestation fields to `strap/src/lib/pkgs/artifacts.json`
2. split `penguin` into a `debian-base + chromeos-vm` overlay
3. add a `bare-git` dotfile backend beside the current `yadm` backend

The `arch-usb` workflow now assembles a Submarine-shaped external disk image
from a cached `arch-rootfs` artifact and the `submarine-x86.kpart` payload.
The shipped image uses an ext4 root partition, and the rootfs stage is built
separately before image assembly.
