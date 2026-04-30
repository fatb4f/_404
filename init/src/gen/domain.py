#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from string import Template
from typing import Any

GENERATED_FILES = {
    "src/templates/domain/domain.env.sh.tmpl": "domain.env.sh",
    "src/templates/domain/files/env.sh.tmpl": "files/env.sh",
    "src/templates/domain/files/init.sh.tmpl": "files/init.sh",
    "src/templates/domain/install.sh.tmpl": "install.sh",
    "src/templates/domain/check.sh.tmpl": "check.sh",
    "src/templates/domain/domain.cue.tmpl": "domain.cue",
}

EXECUTABLE_OUTPUTS = {"install.sh", "check.sh"}
DEFAULT_OUTPUT_DIR = "generated/domains"


def domain_id(domain: dict[str, Any]) -> str:
    return domain.get("output_dir", f"{DEFAULT_OUTPUT_DIR}/{domain['id']}")


def cue_list(values: list[str]) -> str:
    if not values:
        return "[]"
    return "[\n" + "".join(f"\t\t{json.dumps(v)},\n" for v in values) + "\t]"


def cue_records(records: list[dict[str, Any]]) -> str:
    if not records:
        return "[]"
    return json.dumps(records, indent="\t")


def spec_lines(rows: list[list[str]]) -> str:
    return "\n".join("|".join(row) for row in rows)


def derive_paths(roots: dict[str, str], domain: dict[str, Any]) -> dict[str, str]:
    domain_id = domain["id"]
    return {
        "DOTS_REPO": roots.get("dots_repo", "src"),
        "DOTS_DIR": roots.get("dots_dir", "dots"),
        "DOTS_HOME": roots.get("dots", "$HOME/$DOTS_REPO/$DOTS_DIR"),
        "XDG_CONFIG_HOME": roots["xdg_config"],
        "XDG_DATA_HOME": roots["xdg_data"],
        "XDG_OPT_HOME": roots["xdg_opt"],
        "XDG_STATE_HOME": roots["xdg_state"],
        "XDG_CACHE_HOME": roots["xdg_cache"],
        "TOOL_PATH_HOME": roots["tool_path"],
        "DOMAIN_PREFIX": f"$XDG_OPT_HOME/{domain_id}",
        "DOMAIN_STATE": f"$XDG_STATE_HOME/_404/{domain_id}",
        "DOMAIN_CACHE": f"$XDG_CACHE_HOME/_404/{domain_id}",
        "DOMAIN_BIN_HOME": f"$XDG_OPT_HOME/{domain_id}/bin",
        "DOMAIN_SHARE_HOME": f"$XDG_OPT_HOME/{domain_id}/share",
    }


def provider_values(domain: dict[str, Any]) -> dict[str, str]:
    source = domain.get("source") or {}
    npm = source.get("npm") or {}
    cargo = source.get("cargo") or {}
    go = source.get("go") or {}
    bins = domain.get("bins") or []
    deps = domain.get("deps") or {}
    native = deps.get("native") or {}
    packages = native.get("packages") or {}
    host_package = packages.get("arch") or packages.get("debian") or ""
    go_module = go.get("module", "")
    go_version = go.get("version", "")
    if go_module and go_version and "@" not in go_module:
        go_module = f"{go_module}@{go_version}"
    return {
        "DOMAIN_BIN": bins[0] if bins else "",
        "HOST_PACKAGE": host_package,
        "NPM_PACKAGE": npm.get("package", ""),
        "CARGO_CRATE": cargo.get("crate", ""),
        "GO_MODULE": go_module,
    }


def init_source_lines(domain: dict[str, Any]) -> str:
    ns = domain["namespace"]
    lines = []
    for rel in domain.get("init_sources", []):
        lines.append(f'if [ -r "${{{ns}_PREFIX}}/{rel}" ]; then')
        lines.append(f'  . "${{{ns}_PREFIX}}/{rel}"')
        lines.append('fi')
    return "\n".join(lines)


def extra_env_exports(domain: dict[str, Any]) -> str:
    lines = []
    for key, value in (domain.get("extra_env") or {}).items():
        lines.append(f': "${{{key}:={value}}}"')
        lines.append(f'export {key}')
    return "\n".join(lines)


def generated_provides(domain: dict[str, Any], generated_id: str) -> list[str]:
    provides = []
    for value in domain.get("provides", []):
        if value.startswith("domain."):
            provides.append(f"domain.{generated_id}")
        else:
            provides.append(value)
    return provides


def render_values(roots: dict[str, str], domain: dict[str, Any]) -> dict[str, str]:
    paths = derive_paths(roots, domain)
    pv = provider_values(domain)
    generated_id = domain_id(domain)
    files_rows = [[f["source"], f["target"], f.get("mode", "0644")] for f in domain.get("files", [])]
    link_rows = [[l["source"], l["target"]] for l in domain.get("links", [])]
    check_rows = [[c["id"], c["command"], c.get("severity", "degraded")] for c in domain.get("checks", [])]

    requires_ready = []
    for req in domain.get("requires", []):
        if req == "shell.bootstrap.ready":
            requires_ready.append("00-shell")
        elif req == "shell.interactive.ready":
            requires_ready.append("interactive-shell")
        elif req == "terminal.ready":
            requires_ready.append("10-terminal")

    owns = []
    for f in domain.get("files", []):
        owns.append({
            "id": Path(f["source"]).name,
            "source": f["source"],
            "target": f["target"],
            "mode": f.get("mode", "0644"),
            "activation": "atomic-copy",
            "role": "projected",
        })
    for l in domain.get("links", []):
        owns.append({
            "id": Path(l["target"]).name,
            "source": l["source"],
            "target": l["target"],
            "activation": "symlink",
            "role": "activated",
        })

    checks = [
        {"id": c["id"], "command": c["command"], "severity": c.get("severity", "degraded")}
        for c in domain.get("checks", [])
    ]

    return {
        **paths,
        **pv,
        "DOMAIN_ID": generated_id,
        "DOMAIN_NS": domain["namespace"],
        "DOMAIN_STAGE": domain["stage"],
        "DOMAIN_RING": domain["ring"],
        "PROVIDER": domain["provider"],
        "DOMAIN_OUTPUT_DIR": domain.get("output_dir", f"{DEFAULT_OUTPUT_DIR}/{domain['id']}"),
        "DOMAIN_REQUIRES_READY": " ".join(requires_ready),
        "DOMAIN_FILES": spec_lines(files_rows),
        "DOMAIN_LINKS": spec_lines(link_rows),
        "DOMAIN_CHECKS": spec_lines(check_rows),
        "REQUIRES_CUE": cue_list(domain.get("requires", [])),
        "PROVIDES_CUE": cue_list(generated_provides(domain, generated_id)),
        "OWNS_CUE": cue_records(owns),
        "CHECKS_CUE": cue_records(checks),
        "INIT_SOURCE_LINES": init_source_lines(domain),
        "EXTRA_ENV_EXPORTS": extra_env_exports(domain),
    }


def render_template(text: str, values: dict[str, str]) -> str:
    return Template(text).safe_substitute(values)


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate slim.v1 domain artifacts from seed.json")
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument("--seed", default="src/domains/seed.json", help="seed JSON path relative to root")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    seed_path = root / args.seed
    seed = json.loads(seed_path.read_text())
    roots = seed["roots"]

    for domain in seed["domains"]:
        values = render_values(roots, domain)
        domain_dir = root / values["DOMAIN_OUTPUT_DIR"]
        (domain_dir / "files").mkdir(parents=True, exist_ok=True)

        for tmpl_rel, out_rel in GENERATED_FILES.items():
            tmpl = root / tmpl_rel
            out = domain_dir / out_rel
            out.parent.mkdir(parents=True, exist_ok=True)
            rendered = render_template(tmpl.read_text(), values)
            out.write_text(rendered)
            if out_rel in EXECUTABLE_OUTPUTS:
                out.chmod(0o755)
            elif out.suffix == ".sh":
                out.chmod(0o644)


if __name__ == "__main__":
    main()
