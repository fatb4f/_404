# `_404` strap

Host bootstrap is separate from dotfile state.

```text
host-bootstrap
  -> bash-only non-interactive runner
  -> minimal environment files
  -> arch-base/debian-base package deps
  -> GitHub-release userland tools
  -> direct-HOME dotfiles
  -> chsh after dotfiles are live
```

The dotfile authority should track `$HOME` directly with `yadm` or a bare Git repo.

## Host classes

Only two base classes are supported for now:

| Host class | Adapter |
|---|---|
| `arch-base` | `sudo -n pacman -Syu --needed --noconfirm` |
| `debian-base` | `sudo -n apt-get`, `DEBIAN_FRONTEND=noninteractive` |

Penguin/Borealis-style Debian environments collapse to `debian-base`; ChromeOS-specific integration should be added later as an overlay, not as a third base class.

## Non-interactive contract

`strap/bootstrap` runs under Bash and never prompts intentionally.

Package managers use non-interactive flags:

```text
arch-base   -> sudo -n pacman -Syu --needed --noconfirm
debian-base -> sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y
```

`chsh` runs only after dotfiles are live. If it cannot run non-interactively, it prints the manual command and continues with a warning.

Before install, each base-package entry is smoke-tested against the package manager to make sure it resolves in the current distro metadata. If a package does not resolve, bootstrap fails closed before the install step.

## Commands

Dry-run the full flow:

```bash
strap/bootstrap --dry-run
```

Run only host detection:

```bash
strap/bootstrap --stages detect
```

Seed Bash-compatible env files and run doctor:

```bash
strap/bootstrap --stages env,doctor
```

Install system packages only:

```bash
strap/bootstrap --stages pkgs
```

Install userland release tools only:

```bash
strap/bootstrap --stages userland
```

Activate yadm dotfiles, then attempt non-interactive `chsh`:

```bash
DOTFILES_REPO_URL='git@github.com:USER/dotfiles.git' \
  strap/bootstrap --stages dotfiles,chsh,doctor
```

Import the repository `home/` overlay into `$HOME` before yadm activation:

```bash
strap/bootstrap --import-home-tree --stages dotfiles,chsh,doctor
```

## Package-manager deps

`jq`, `gh`, and `npm` are package-manager dependencies, not userland release artifacts.
There is no shared `common.pkgs` layer; package names are adapter-specific.
`base-devel` is the shared build-tool intent; on Arch it resolves to `base-devel`, and on Debian it resolves through `build-essential`.

Concrete package lists:

```text
strap/src/lib/pkgs/arch-base.pkgs
strap/src/lib/pkgs/debian-base.pkgs
```

The package lists stay host-specific because Arch and Debian package names diverge.

## Userland artifacts

Userland packages are declared in:

```text
strap/src/lib/pkgs/artifacts.json
```

The installer filters that manifest with `jq`:

```bash
jq -c '.artifacts[] | select((.enabled // true) == true)' \
  strap/src/lib/pkgs/artifacts.json
```

For each selected row, it downloads the latest matching GitHub release asset with:

```bash
gh release download -R "$repo" --pattern "$pkg" --dir "$tmp"
```

Before downloading, the installer smoke-tests the pattern against the latest
release asset list from the manager and fails closed if nothing matches.

Default locations:

```text
~/.local/bin                         executable files and symlinks
~/.local/opt                         extracted application trees for opt installs
$XDG_CACHE_HOME/_404/artifacts       release download cache
$XDG_STATE_HOME/_404/userland-installed.tsv
```

Install modes:

| mode | behavior |
|---|---|
| `bin` | extract the artifact and install selected binaries into `~/.local/bin` |
| `opt` | extract to `~/.local/opt/<name>` and symlink selected binaries into `~/.local/bin` |

`kitty` and `neovim` use `opt` mode.
