---
name: hof
description: Use this skill when the task is to drive a bounded `hof` workflow for spec ingestion, CUE normalization, deterministic code generation, schema emission, or verification from a skill-local task graph.
---

# Hof Skill

## Purpose

Use this skill for the narrow `hof`-based spec-to-python workflow recovered under `/home/x404/.local/opt/knowledge/10-areas/local.stack/runtime/skill-spec-python`.

`hof` is not the semantic authority. It is the bounded task runner and projection engine over contracts that already exist.

## Use This Skill When

- the request is to run or inspect a `hof` task flow
- the workflow is rooted in `tasks/flow.cue`
- the user wants deterministic generation from CUE/spec inputs
- the job is to emit Python or schemas from a skill-local task graph
- the user is working inside `/home/x404/.local/opt/knowledge/10-areas/local.stack/runtime/skill-spec-python`

## Do Not Use This Skill For

- ad hoc shell scripting without a `hof` task graph
- proposal authoring or promotion gating
- JSON normalization when `json-tool` is the real authority
- generic code generation outside the recovered spec-to-python workflow

## Canonical Workspace

Primary recovered workspace:

- `/home/x404/.local/opt/knowledge/10-areas/local.stack/runtime/skill-spec-python`

High-signal files:

- `AGENTS.md`
- `control/task-contract.md`
- `tasks/flow.cue`
- `tasks/*.hof`
- `generators/python/hof.module.cue`
- `specs/cue/*.cue`
- `scripts/generate_python.py`
- `scripts/generate_schemas.py`
- `scripts/write_validation_report.py`
- `scripts/write_verify_report.py`

## Operating Rules

- Start from the `skill-spec-python` root.
- Read the nearest `AGENTS.md` before traversing deeper.
- Treat `.hof` files as bounded task contracts, not general-purpose notes.
- Keep generation deterministic and contract-first.
- Prefer emitted reports over prose claims when judging success.

## Default Commands

Run from the `skill-spec-python` root:

```bash
hof flow tasks/flow.cue @specToPython
hof flow tasks/flow.cue @generateSchemas
hof flow tasks/flow.cue @validate
hof flow tasks/flow.cue @verify
```

If the task graph is unavailable or drifted, stop and inspect `control/task-contract.md` plus the nearest `AGENTS.md` files before improvising.

## Output Contract

When using this skill, report:

- which `hof` target was used
- which source contracts were consumed
- which generated artifacts changed
- which validation or verification report was produced

Prefer file-backed artifacts under `generated/` over ad hoc summaries.
