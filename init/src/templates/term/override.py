from __future__ import annotations

from typing import Any


def project(fragment: dict[str, Any]) -> dict[str, Any]:
    return {
        "generated_files_add": {
            "src/templates/domain/files/bin/kitty-zsh-max.tmpl": "files/bin/kitty-zsh-max",
        },
    }
