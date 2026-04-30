# slim.v1 base

Seed-generated migration base for the `_404` slim workflow.

The branch separates repo-owned authored/payload roots from host-owned runtime and activation roots.

```txt
repo-owned roots:
  DOTS_REPO=src
  DOTS_DIR=dots
  DOTS_HOME=$HOME/$DOTS_REPO/$DOTS_DIR
  XDG_CONFIG_HOME=$DOTS_HOME/.config
  XDG_DATA_HOME=$DOTS_HOME/.local/share
  XDG_OPT_HOME=$DOTS_HOME/.local/opt

host-owned roots:
  XDG_STATE_HOME=$HOME/.local/state
  XDG_CACHE_HOME=$HOME/.cache
  TOOL_PATH_HOME=$HOME/.local/bin
```

The important distinction:

```txt
$DOTS_HOME/.local/opt/<domain> = payload ownership
$TOOL_PATH_HOME/<cmd>          = execution activation surface
$XDG_STATE_HOME/_404           = ready markers / reports / evidence
$XDG_CACHE_HOME                = disposable cache
```

`DOTS_REPO` and `DOTS_DIR` are seed/render variables so the checkout can move from `$HOME/src/dots` to any `$HOME/$repo/$dir` shape without hand-editing generated artifacts.

## Current generated layout

Generated domains live under the reorganized bootstrap layout:

```txt
generated/init/noninteractive-shell/
generated/init/interactive-shell/
generated/init/term/kitty/
generated/postinit/codex/
```

Each generated domain contains:

```txt
files/
  env.sh
  init.sh
check.sh
domain.cue
domain.env.sh
install.sh
```

Generated scripts discover the repository root by walking upward until `src/lib/fs.sh` and `src/lib/domain.sh` are found. This avoids assuming a fixed depth such as `<domain>/..`.

## Authored inputs

```txt
domains/seed.json             zero-dependency bootstrap seed
domains/seed.cue              CUE authority seed mirror
src/schema/domain-seed.cue    seed contract
src/schema/domain.cue         materialized domain contract
src/templates/domain/*        projection templates
src/gen/domain.py             seed renderer
src/lib/*                     shared runtime adapters
```

## Generate

```sh
python3 src/gen/domain.py --root . --seed domains/seed.json
```

## Validate

```sh
just check-generated
just regen-check
```

Direct shell-only validation:

```sh
python3 -m py_compile src/gen/domain.py
find generated src -name '*.sh' -print | xargs -r sh -n
```

## Dry-run install

```sh
just dry-run
```

or explicitly:

```sh
DOMAIN_DRY_RUN=1 sh generated/init/noninteractive-shell/install.sh
DOMAIN_DRY_RUN=1 sh generated/init/interactive-shell/install.sh
DOMAIN_DRY_RUN=1 sh generated/init/term/kitty/install.sh
DOMAIN_DRY_RUN=1 sh generated/postinit/codex/install.sh
```

## Migration note

Current `slim` can keep its robust workflow shape: domain-local install/check/files, atomic copy, atomic symlink activation, ready markers, dry-run mode, and read-only doctor checks.

`slim.v1` changes the root vocabulary:

```txt
old assumption:
  standard host XDG paths and fixed domain depth

new seed model:
  DOTS_HOME=$HOME/$DOTS_REPO/$DOTS_DIR
  repo XDG config/data/opt roots
  host state/cache/tool-path roots
  generated scripts with repo-root discovery
```
