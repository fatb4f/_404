#!/usr/bin/env python3
from __future__ import annotations

import argparse
import importlib.util
import json
import shutil
from pathlib import Path
from typing import Any

BASE_GENERATED_FILES = {
    "src/templates/domain/domain.env.sh.tmpl": "domain.env.sh",
    "src/templates/domain/files/env.sh.tmpl": "files/env.sh",
    "src/templates/domain/files/init.sh.tmpl": "files/init.sh",
    "src/templates/domain/install.sh.tmpl": "install.sh",
    "src/templates/domain/check.sh.tmpl": "check.sh",
    "src/templates/domain/domain.cue.tmpl": "domain.cue",
}

NONINTERACTIVE_SHELL_FILES = {
    "src/templates/domain/files/env-loader.sh.tmpl": "files/env-loader.sh",
    "src/templates/domain/files/bash_profile.tmpl": "files/bash_profile",
    "src/templates/domain/files/bashrc.tmpl": "files/bashrc",
}

INTERACTIVE_SHELL_FILES = {
    "src/templates/domain/files/zshenv.tmpl": "files/zshenv",
    "src/templates/domain/files/zshrc.tmpl": "files/zshrc",
}

EXECUTABLE_OUTPUTS = {
    "install.sh",
    "check.sh",
}
DEFAULT_OUTPUT_DIR = "generated/domains"


def cue_list(values: list[str]) -> str:
    if not values:
        return "[]"
    return "[\n" + "".join(f"\t\t{json.dumps(v)},\n" for v in values) + "\t]"


def cue_records(records: list[dict[str, Any]]) -> str:
    if not records:
        return "[]"
    return json.dumps(records, indent="\t")


def spec_lines(rows: list[list[str]]) -> str:
    def escape(value: str) -> str:
        return value.replace("'", "'\"'\"'")

    return "\n".join("|".join(escape(col) for col in row) for row in rows)


def load_template_override(root: Path, domain: dict[str, Any]) -> dict[str, Any]:
    template_override = domain.get("template_override")
    if not template_override:
        return {}

    override = root / "src" / "templates" / template_override / "override.py"
    if not override.exists():
        return {}

    spec = importlib.util.spec_from_file_location(
        f"template_override_{template_override}",
        override,
    )
    if spec is None or spec.loader is None:
        raise SystemExit(f"{override}: unable to load override")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)

    project = getattr(module, "project", None)
    if project is None:
        project = getattr(module, "normalize", None)
    if project is None:
        return {}

    result = project(dict(domain))
    if not isinstance(result, dict):
        raise SystemExit(f"{override}: project()/normalize() must return a dict")
    return result


def apply_template_patch(
    domain: dict[str, Any],
    generated_files: dict[str, str],
    patch: dict[str, Any],
) -> None:
    def dedupe_by_key(items: list[dict[str, Any]], key: str) -> list[dict[str, Any]]:
        seen = set()
        out = []
        for item in items:
            value = item.get(key)
            if value in seen:
                continue
            seen.add(value)
            out.append(item)
        return out

    for rel in patch.get("generated_files_remove") or []:
        generated_files.pop(rel, None)
    for rel, out_rel in (patch.get("generated_files_add") or {}).items():
        generated_files[rel] = out_rel

    file_specs = list(domain.get("files") or [])
    remove_sources = set(patch.get("files_remove") or [])
    if remove_sources:
        file_specs = [item for item in file_specs if item.get("source") not in remove_sources]
    file_specs.extend(patch.get("files_add") or [])
    domain["files"] = dedupe_by_key(file_specs, "source")

    copy_specs = list(domain.get("copies") or [])
    copy_specs.extend(patch.get("copies") or [])
    if copy_specs:
        domain["copies"] = dedupe_by_key(copy_specs, "dst")

    check_specs = list(domain.get("checks") or [])
    remove_checks = set(patch.get("checks_remove") or [])
    if remove_checks:
        check_specs = [item for item in check_specs if item.get("id") not in remove_checks]
    check_specs.extend(patch.get("checks_add") or [])
    domain["checks"] = dedupe_by_key(check_specs, "id")

    template_values = dict(domain.get("template_values") or {})
    template_values.update(patch.get("template_values") or {})
    if template_values:
        domain["template_values"] = template_values

    cleanup_outputs = list(domain.get("cleanup_outputs") or [])
    cleanup_outputs.extend(patch.get("cleanup_outputs") or [])
    if cleanup_outputs:
        domain["cleanup_outputs"] = cleanup_outputs


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


def shell_env_source_lines(domains: list[dict[str, Any]]) -> str:
    lines = []
    for domain in domains:
        domain_id = domain["id"]
        if not any(f.get("source") == "files/env.sh" for f in domain.get("files", [])):
            continue
        lines.append(f'if [ -r "$XDG_OPT_HOME/{domain_id}/env.sh" ]; then')
        lines.append(f'  . "$XDG_OPT_HOME/{domain_id}/env.sh"')
        lines.append('fi')
    lines.append('if [ -r "$XDG_OPT_HOME/0-noninteractive-shell/path.sh" ]; then')
    lines.append('  . "$XDG_OPT_HOME/0-noninteractive-shell/path.sh"')
    lines.append('fi')
    return "\n".join(lines)


def render_values(roots: dict[str, str], domain: dict[str, Any], domains: list[dict[str, Any]]) -> dict[str, str]:
    paths = derive_paths(roots, domain)
    pv = provider_values(domain)
    files_rows = [[f["source"], f["target"], f.get("mode", "0644")] for f in domain.get("files", [])]
    copy_rows = [[c["src"], c["dst"], c.get("mode", "0644")] for c in domain.get("copies", [])]
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
    for c in domain.get("copies", []):
        owns.append({
            "id": Path(c["dst"]).name,
            "source": c["src"],
            "target": c["dst"],
            "mode": c.get("mode", "0644"),
            "activation": "atomic-copy",
            "role": "activated",
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

    extra_env_exports_text = extra_env_exports(domain)
    template_values = domain.get("template_values") or {}
    domain_env_extra = template_values.get("DOMAIN_ENV_EXTRA", "")
    if domain_env_extra:
        domain_env_extra = str(domain_env_extra).rstrip("\n")
        if extra_env_exports_text:
            extra_env_exports_text = f"{extra_env_exports_text}\n{domain_env_extra}"
        else:
            extra_env_exports_text = domain_env_extra

    return {
        **paths,
        **pv,
        "DOMAIN_ID": domain["id"],
        "DOMAIN_NS": domain["namespace"],
        "DOMAIN_STAGE": domain["stage"],
        "DOMAIN_RING": domain["ring"],
        "PROVIDER": domain["provider"],
        "DOMAIN_OUTPUT_DIR": domain.get("output_dir", f"{DEFAULT_OUTPUT_DIR}/{domain['id']}"),
        "DOMAIN_REQUIRES_READY": " ".join(requires_ready),
        "DOMAIN_FILES": spec_lines(files_rows),
        "DOMAIN_COPIES": spec_lines(copy_rows),
        "DOMAIN_LINKS": spec_lines(link_rows),
        "DOMAIN_CHECKS": spec_lines(check_rows),
        "DOMAIN_INIT_EXTRA": "",
        "REQUIRES_CUE": cue_list(domain.get("requires", [])),
        "PROVIDES_CUE": cue_list(domain.get("provides", [])),
        "OWNS_CUE": cue_records(owns),
        "CHECKS_CUE": cue_records(checks),
        "INIT_SOURCE_LINES": init_source_lines(domain),
        "SHELL_ENV_SOURCE_LINES": shell_env_source_lines(domains),
        "EXTRA_ENV_EXPORTS": extra_env_exports_text,
        **(domain.get("template_values") or {}),
    }


def render_template(text: str, values: dict[str, str]) -> str:
    # Deliberately use @TOKEN@ placeholders instead of string.Template.
    # Shell files contain many runtime $VARS; replacing only @TOKENS@
    # avoids freezing XDG_STATE_HOME/TOOL_PATH_HOME into generated shims.
    for key, value in values.items():
        text = text.replace(f"@{key}@", str(value))
    return text


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate slim.v1 domain artifacts from seed.json")
    parser.add_argument("--root", default=".", help="repository root")
    parser.add_argument("--seed", default="src/domains/seed.json", help="seed JSON path relative to root")
    args = parser.parse_args()

    root = Path(args.root).resolve()
    seed_path = root / args.seed
    seed = json.loads(seed_path.read_text())
    roots = seed["roots"]
    domains = seed["domains"]

    for domain in domains:
        domain = dict(domain)
        generated_files = dict(BASE_GENERATED_FILES)
        if domain.get("stage") == "00-shell":
            generated_files.update(NONINTERACTIVE_SHELL_FILES)
        if domain.get("stage") == "interactive-shell":
            generated_files.update(INTERACTIVE_SHELL_FILES)

        patch = load_template_override(root, domain)
        if patch:
            apply_template_patch(domain, generated_files, patch)

        values = render_values(roots, domain, domains)
        domain_dir = root / values["DOMAIN_OUTPUT_DIR"]
        domain_dir.mkdir(parents=True, exist_ok=True)
        (domain_dir / "files").mkdir(parents=True, exist_ok=True)

        for rel in domain.get("cleanup_outputs") or []:
            target = domain_dir / rel
            if target.is_dir() and not target.is_symlink():
                shutil.rmtree(target, ignore_errors=True)
            elif target.exists() or target.is_symlink():
                target.unlink()

        file_modes = {f["source"]: f.get("mode", "0644") for f in domain.get("files", [])}
        for tmpl_rel, out_rel in generated_files.items():
            tmpl = root / tmpl_rel
            out = domain_dir / out_rel
            out.parent.mkdir(parents=True, exist_ok=True)
            rendered = render_template(tmpl.read_text(), values)
            out.write_text(rendered)
            mode = file_modes.get(out_rel)
            if out_rel in EXECUTABLE_OUTPUTS:
                out.chmod(0o755)
            elif mode:
                out.chmod(int(mode, 8))
            elif out.suffix == ".sh":
                out.chmod(0o644)


if __name__ == "__main__":
    main()
