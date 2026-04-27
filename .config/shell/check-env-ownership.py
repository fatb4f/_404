#!/usr/bin/env python3
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1]) if len(sys.argv) > 1 else Path.home() / ".config/shell"
ENV_D = ROOT / "env.d"

OWNER_RULES: dict[str, set[str]] = {
    "00-xdg.sh": {
        "XDG_CACHE_HOME",
        "XDG_CONFIG_HOME",
        "XDG_DATA_HOME",
        "XDG_STATE_HOME",
        "XDG_CONFIG_DIRS",
        "XDG_DATA_DIRS",
    },
    "10-cache.sh": {
        "PIP_CACHE_DIR",
        "PYTHONPYCACHEPREFIX",
        "RUFF_CACHE_DIR",
        "UV_CACHE_DIR",
        "PYTEST_ADDOPTS",
        "ZSH_CACHE_DIR",
    },
    "20-paths.sh": {
        "XDG_DATA_BIN",
        "TOOL_PATH_HOME",
        "PATH",
    },
    "30-toolchains.sh": {
        "GOPATH",
        "GOBIN",
        "CARGO_HOME",
        "RUSTUP_HOME",
        "CC",
        "CXX",
    },
    "35-dirs.sh": {
        "GDRIVE",
        "PRJROOT",
        "DIR_SRC",
        "DIR_WORK",
        "DIR_WIKI",
        "DIR_DOTS",
        "DIR_BOOTSTRAP",
        "DIRS",
    },
    "40-apps.sh": {
        "EDITOR",
        "VISUAL",
        "KITTY_CONFIG_DIRECTORY",
        "KITTY_CACHE_DIRECTORY",
        "ANDROID_USER_HOME",
        "GNUPGHOME",
        "PASSWORD_STORE_DIR",
        "CODEX_HOME",
        "CODEX_STATE",
        "LESSHISTFILE",
    },
}

ASSIGN_RE = re.compile(r"^\s*(?:export\s+)?([A-Z][A-Z0-9_]*)\s*(?:[+]?=)")
BARE_EXPORT_RE = re.compile(r"^\s*export\s+(.+)$")


def strip_comment(line: str) -> str:
    return line.split("#", 1)[0].strip()


def assigned_vars(path: Path) -> set[str]:
    found: set[str] = set()

    for raw in path.read_text().splitlines():
        line = strip_comment(raw)
        if not line:
            continue

        match = ASSIGN_RE.match(line)
        if match:
            found.add(match.group(1))
            continue

        export_match = BARE_EXPORT_RE.match(line)
        if export_match:
            for token in export_match.group(1).split():
                if "=" in token:
                    name = token.split("=", 1)[0]
                    if re.fullmatch(r"[A-Z][A-Z0-9_]*", name):
                        found.add(name)

    return found


def main() -> int:
    errors: list[str] = []

    owners_by_var: dict[str, list[str]] = {}
    for file in sorted(ENV_D.glob("*.sh")):
        vars_in_file = assigned_vars(file)

        if file.name == "20-paths.sh":
            text = file.read_text()
            if "path_prepend_dir" in text or "path_prepend" in text:
                vars_in_file.add("PATH")

        allowed = OWNER_RULES.get(file.name, set())
        extra = sorted(vars_in_file - allowed)
        if extra:
            errors.append(f"{file.name}: owns undeclared variable(s): {', '.join(extra)}")

        for var in vars_in_file:
            owners_by_var.setdefault(var, []).append(file.name)

    for var, owners in sorted(owners_by_var.items()):
        if len(owners) > 1:
            errors.append(f"{var}: assigned by multiple fragments: {', '.join(owners)}")

    for file_name, allowed in OWNER_RULES.items():
        path = ENV_D / file_name
        if not path.exists():
            continue

        actual = assigned_vars(path)
        if file_name == "20-paths.sh" and ("path_prepend_dir" in path.read_text() or "path_prepend" in path.read_text()):
            actual.add("PATH")

        missing = sorted(v for v in allowed if v not in actual)
        if missing:
            print(
                f"warn: {file_name}: declared owner but no direct assignment for: {', '.join(missing)}",
                file=sys.stderr,
            )

    if errors:
        for err in errors:
            print(f"error: {err}", file=sys.stderr)
        return 1

    print("shell env ownership validation passed")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
