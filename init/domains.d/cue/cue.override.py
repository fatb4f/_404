from __future__ import annotations


def normalize(fragment: dict) -> dict:
    """Normalize the minimal CUE toolchain fragment."""

    fragment = dict(fragment)

    def add_check(checks: list[dict], check_id: str, command: str, severity: str = "fatal") -> None:
        if any(check.get("id") == check_id for check in checks):
            return
        checks.append({
            "id": check_id,
            "command": command,
            "severity": severity,
        })

    checks = list(fragment.get("checks") or [])
    primary_bin = (fragment.get("bins") or [None])[0]
    if primary_bin:
        add_check(checks, f"{fragment.get('id', 'tool')}-available", f"command -v {primary_bin} >/dev/null 2>&1")
    add_check(checks, "cue-version", "cue version >/dev/null 2>&1")
    add_check(checks, "cue-vet-help", "cue vet --help >/dev/null 2>&1")
    fragment["checks"] = checks
    return fragment
