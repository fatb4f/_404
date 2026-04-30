from __future__ import annotations


def normalize(fragment: dict) -> dict:
    """Normalize the Rust toolchain fragment."""

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
    add_check(checks, "rustc-available", "command -v rustc >/dev/null 2>&1")
    add_check(checks, "cargo-available", "command -v cargo >/dev/null 2>&1")
    add_check(checks, "rustfmt-available", "command -v rustfmt >/dev/null 2>&1")
    add_check(checks, "clippy-driver-available", "command -v clippy-driver >/dev/null 2>&1")
    add_check(checks, "rustc-version", "rustc --version >/dev/null 2>&1")
    add_check(checks, "cargo-version", "cargo --version >/dev/null 2>&1")
    add_check(checks, "rustfmt-version", "rustfmt --version >/dev/null 2>&1")
    add_check(checks, "cargo-clippy-version", "cargo clippy --version >/dev/null 2>&1")
    fragment["checks"] = checks

    template_values = dict(fragment.get("template_values") or {})
    template_values["DOMAIN_ENV_EXTRA"] = (
        ': "${CARGO_HOME:=$XDG_DATA_HOME/cargo}"\n'
        'if command -v _path_prepend >/dev/null 2>&1; then\n'
        '  _path_prepend "$CARGO_HOME/bin"\n'
        'else\n'
        '  case ":$PATH:" in\n'
        '    *":$CARGO_HOME/bin:"*) ;;\n'
        '    *) PATH="$CARGO_HOME/bin${PATH:+:$PATH}"; export PATH ;;\n'
        '  esac\n'
        'fi\n'
        'export CARGO_HOME PATH'
    )
    fragment["template_values"] = template_values
    return fragment
