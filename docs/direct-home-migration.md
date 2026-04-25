# Direct-HOME migration notes

The uploaded tree was still partly in chezmoi source form. For direct `$HOME` tracking, filenames must be the real target filenames.

Applied conversion inside `home/`:

| Old source convention | Direct-HOME target |
|---|---|
| `dot_zshrc` | `.zshrc` |
| `dot_neoconf.json` | `.neoconf.json` |
| `executable_foo` | `foo` with mode `0755` |
| `readonly_main.lua` | `main.lua` |
| `empty_config.yml` | `config.yml` |

The `home/` directory is now a direct `$HOME` overlay. That means it can be imported with:

```bash
rsync -a home/ "$HOME"/
yadm add ~/.zshenv ~/.config ~/.local/bin
```

The bootstrap layer can also import it explicitly:

```bash
strap/bootstrap --import-home-tree --stages dotfiles,chsh,doctor
```

Bootstrap no longer writes `.zshenv` or any zsh entrypoint. Zsh config belongs to the dotfiles authority. The only zsh-specific host action is `chsh`, and it runs after dotfiles are live.

Do not put chezmoi-style filename prefixes back under `home/` unless the authority switches back to chezmoi.
