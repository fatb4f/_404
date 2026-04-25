#!/usr/bin/env bash
set -euo pipefail

exec kitten @ action launch --type=tab --cwd=current --add-to-session=. /usr/bin/env zsh -l
