from __future__ import annotations


def normalize(fragment: dict) -> dict:
    """Optional local transform for one domains.d fragment.

    Contract:
      - read one fragment dict
      - return one normalized fragment dict
      - no side effects
      - no filesystem or network writes
    """
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
    add_check(checks, "gofmt-available", "command -v gofmt >/dev/null 2>&1")
    add_check(checks, "go-env-probe", "go env GOPATH GOBIN GOMODCACHE >/dev/null 2>&1")
    fragment["checks"] = checks

    template_values = dict(fragment.get("template_values") or {})
    template_values.setdefault(
        "DOMAIN_ENV_EXTRA",
        "\n".join([
            ': "${GOPATH:=$HOME/go}"',
            ': "${GOBIN:=$GOPATH/bin}"',
            'if command -v _path_prepend >/dev/null 2>&1; then',
            '  _path_prepend "$GOBIN"',
            'else',
            '  case ":$PATH:" in',
            '    *":$GOBIN:"*) ;;',
            '    *) PATH="$GOBIN${PATH:+:$PATH}"; export PATH ;;',
            '  esac',
            'fi',
            'export GOPATH GOBIN PATH',
        ]),
    )
    fragment["template_values"] = template_values
    return fragment
