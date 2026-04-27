# Dotfiles Provisioning Seed

This directory holds the phase-0 entrypoint for a new machine.

Usage:

```bash
DOTFILES_REPO=https://github.com/fatb4f/_404.git \
  bash ~/.config/dotfiles-provision/seed.sh
```

What it does:

1. Requires `git` and `yadm`.
2. Clones the dotfiles repo if yadm is not already initialized.
3. Runs `yadm bootstrap`.
4. Sources the managed shell env loader if present.
5. Runs `just check` when `just` is available.

What it does not do:

1. It does not decide policy.
2. It does not classify drift.
3. It does not manage dotfiles directly.
4. It does not install host packages.
