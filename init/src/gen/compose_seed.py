#!/usr/bin/env python3
from __future__ import annotations

import argparse
import importlib.util
import json
from pathlib import Path
from typing import Any


def load_yaml_or_json(path: Path) -> dict[str, Any]:
    text = path.read_text()
    stripped = text.lstrip()
    if stripped.startswith("{") or stripped.startswith("["):
        return json.loads(text)
    try:
        import yaml  # type: ignore
    except Exception as exc:
        raise SystemExit(
            f"{path}: YAML fragments require PyYAML unless they are JSON-compatible YAML"
        ) from exc
    data = yaml.safe_load(text)
    if not isinstance(data, dict):
        raise SystemExit(f"{path}: fragment must decode to an object")
    return data


def run_override(fragment_path: Path, fragment: dict[str, Any]) -> dict[str, Any]:
    override = fragment_path.with_suffix(".override.py")
    if not override.exists():
        return fragment

    spec = importlib.util.spec_from_file_location(f"override_{fragment_path.stem}", override)
    if spec is None or spec.loader is None:
        raise SystemExit(f"{override}: unable to load override")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    normalize = getattr(module, "normalize", None)
    if normalize is None:
        return fragment
    result = normalize(dict(fragment))
    if not isinstance(result, dict):
        raise SystemExit(f"{override}: normalize() must return a dict")
    return result


def main() -> None:
    parser = argparse.ArgumentParser(description="Compose base seed with domains.d fragments")
    parser.add_argument("--root", default=".")
    parser.add_argument("--seed", default="src/domains/seed.json")
    parser.add_argument("--fragments", default="domains.d")
    parser.add_argument("--out", default="src/domains/seed.composed.json")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    seed_path = root / args.seed
    fragments_dir = root / args.fragments

    seed = json.loads(seed_path.read_text())
    domains = {d["id"]: d for d in seed.get("domains", [])}

    if fragments_dir.exists():
        for path in sorted(list(fragments_dir.glob("*/*.json")) + list(fragments_dir.glob("*/*.yml")) + list(fragments_dir.glob("*/*.yaml"))):
            fragment = load_yaml_or_json(path)
            fragment = run_override(path, fragment)
            domain_id = fragment.get("id")
            if not domain_id:
                raise SystemExit(f"{path}: missing id")
            domains[domain_id] = fragment

    seed["domains"] = list(domains.values())
    out = root / args.out
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(seed, indent=2) + "\n")


if __name__ == "__main__":
    main()
