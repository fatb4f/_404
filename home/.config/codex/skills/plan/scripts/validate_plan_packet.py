#!/usr/bin/env python3
"""Validate plan packet structure and git-flow contract outputs."""

from __future__ import annotations

import argparse
import json
import os
import re
from dataclasses import dataclass
from pathlib import Path

import jsonschema

REQUIRED_SECTIONS = [
    'artifact_paths',
    'bounded_batch',
    'contract_context',
    'problem_set',
    'scope',
    'assets_required',
    'assets_impacted',
    'dependency_matrix',
    'integration_worktree_plan',
    'gate_plan',
    'promotion_plan',
    'rollback_plan',
    'decision',
    'implement',
    'success_criteria',
]
VALID_STATUSES = {'APPROVED', 'REJECTED', 'NEEDS_INFO'}
HEADING_RE = re.compile(r'^##\s+([A-Za-z0-9_ -]+)\s*$')
FIELD_RE = re.compile(r'^-\s+([^:]+):\s*(.*)$')


@dataclass
class Section:
    name: str
    text: str


def load_sections(lines: list[str]) -> dict[str, Section]:
    matches: list[tuple[str, int]] = []
    for idx, line in enumerate(lines):
        m = HEADING_RE.match(line.strip())
        if m:
            matches.append((m.group(1).strip(), idx))
    sections: dict[str, Section] = {}
    for i, (name, start) in enumerate(matches):
        end = matches[i + 1][1] if i + 1 < len(matches) else len(lines)
        sections[name] = Section(name=name, text='\n'.join(lines[start + 1:end]).strip())
    return sections


def parse_fields(text: str) -> dict[str, str]:
    out: dict[str, str] = {}
    for line in text.splitlines():
        m = FIELD_RE.match(line.strip())
        if m:
            out[m.group(1).strip()] = m.group(2).strip()
    return out


def load_json_file(path: Path) -> tuple[object | None, str | None]:
    try:
        return json.loads(path.read_text(encoding='utf-8')), None
    except Exception as exc:  # pragma: no cover - surfaced as packet validation output
        return None, str(exc)


def validate_instance(instance: object, schema_path: Path) -> list[str]:
    schema = json.loads(schema_path.read_text(encoding='utf-8'))
    resolver = jsonschema.validators.RefResolver(base_uri=schema_path.resolve().as_uri(), referrer=schema)
    validator = jsonschema.Draft202012Validator(schema, resolver=resolver)
    return [e.message for e in validator.iter_errors(instance)]


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('path', nargs='?', default='README.md')
    p.add_argument('--wt', default=None)
    p.add_argument('--contract-root', default='.')
    p.add_argument('--mode', choices=('scaffold', 'ready'), default='scaffold')
    args = p.parse_args()

    path = Path(args.path).expanduser().resolve()
    wt = Path(args.wt or os.environ.get('WT') or path.parent.parent).expanduser().resolve()
    contract_root = Path(args.contract_root).expanduser().resolve()
    if not path.exists():
        raise SystemExit(f'file not found: {path}')

    lines = path.read_text(encoding='utf-8').splitlines()
    sections = load_sections(lines)
    errors: list[str] = []
    for sec in REQUIRED_SECTIONS:
        if sec not in sections:
            errors.append(f'missing section: ## {sec}')

    decision_fields = parse_fields(sections.get('decision', Section('decision', '')).text)
    status = decision_fields.get('Status', '')
    if status and status not in VALID_STATUSES and '| ' not in status:
        errors.append(f'decision status invalid: {status}')

    plan_dir = wt / 'PLAN'
    parsed_plan_json: dict[str, object] = {}
    for json_path in sorted(plan_dir.glob('*.json')):
        payload, err = load_json_file(json_path)
        if err:
            errors.append(f'{json_path.name} invalid JSON: {err}')
        else:
            parsed_plan_json[json_path.name] = payload

    required = {
        'contract.bindings.json': contract_root / 'schemas/contract_bindings.schema.json',
        'request.instance.json': contract_root / 'schemas/request.schema.json',
        'batch.manifest.json': contract_root / 'schemas/batch_manifest.schema.json',
        'integration_gate.plan.json': contract_root / 'schemas/integration_gate_plan.schema.json',
        'promotion.plan.json': contract_root / 'schemas/promotion_plan.schema.json',
    }
    for fname, schema in required.items():
        fpath = plan_dir / fname
        if not fpath.exists():
            errors.append(f'missing artifact: {fpath}')
        elif fname != 'contract.bindings.json' and fname in parsed_plan_json:
            for err in validate_instance(parsed_plan_json[fname], schema):
                errors.append(f'{fname}: {err}')
    bindings_path = plan_dir / 'contract.bindings.json'
    if bindings_path.exists():
        try:
            bindings = parsed_plan_json.get('contract.bindings.json')
            if bindings is None:
                raise ValueError('invalid JSON')
            schema = json.loads((contract_root / 'schemas/contract_bindings.schema.json').read_text(encoding='utf-8'))
            jsonschema.Draft202012Validator(schema).validate(bindings)
        except Exception as exc:
            errors.append(f'contract.bindings.json invalid: {exc}')

    req_val_path = plan_dir / 'request.validation.json'
    if not req_val_path.exists():
        errors.append(f'missing artifact: {req_val_path}')
    else:
        req_val = parsed_plan_json.get('request.validation.json')
        if isinstance(req_val, dict) and args.mode == 'ready' and not req_val.get('valid'):
            errors.append('request.validation.json reports valid=false')

    if errors:
        print('FAIL')
        for err in errors:
            print(f'- {err}')
        return 1
    print('OK')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
