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

    checks = list(fragment.get("checks") or [])
    primary_bin = (fragment.get("bins") or [None])[0]
    if primary_bin:
        check_id = f"{fragment.get('id', 'tool')}-available"
        if not any(check.get("id") == check_id for check in checks):
            checks.append({
                "id": check_id,
                "command": f"command -v {primary_bin} >/dev/null 2>&1",
                "severity": "fatal",
            })
    fragment["checks"] = checks
    return fragment
