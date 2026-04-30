from __future__ import annotations


def normalize(fragment: dict) -> dict:
    """Normalize the ripgrep cargo-binstall fragment."""

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
    add_check(checks, "rg-available", "command -v rg >/dev/null 2>&1")
    add_check(checks, "cargo-available", "command -v cargo >/dev/null 2>&1")
    add_check(checks, "cargo-binstall-available", "command -v cargo-binstall >/dev/null 2>&1", "degraded")
    add_check(checks, "rg-version", "rg --version >/dev/null 2>&1")
    fragment["checks"] = checks
    return fragment
