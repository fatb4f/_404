---
name: chezmoi
description: Use this skill when working on the canonical tracked Codex home under `dotfiles/chezmoi/dot_config`, especially to prevent split-brain edits between live config, mirror paths, and the chezmoi-owned source tree.
---

# Chezmoi Skill

## Purpose

Use this skill when the task touches files managed by the `dotfiles` chezmoi tree.

For Codex, the canonical tracked source of truth is:

- `chezmoi/dot_config/codex`

The compatibility mirror:

- `config/codex`

The live resolved home:

- `~/.config/codex`

## Use This Skill When

- the user wants to edit tracked config under `dotfiles`
- the task involves syncing `chezmoi/dot_config/...` and live `~/.config/...`
- you need to verify which path is authoritative
- the task risks split-brain duplication between `config/` and `chezmoi/dot_config/`
- the request is about recovering, moving, or normalizing Codex config layout

## Core Rules

- Treat `chezmoi/dot_config` as the only tracked authority.
- Treat `config/` as a mirror or compatibility path, never a second authored tree.
- Do not create parallel owned copies of the same config subtree.
- When recovering live state, restore authored surfaces into the chezmoi path first.
- Exclude runtime noise such as caches, logs, sessions, auth material, and sqlite state from tracked recovery unless explicitly requested.

## Codex Layout

For this repo, the intended Codex layout is:

- `dotfiles/chezmoi/dot_config/codex` -> real tracked tree
- `dotfiles/config/codex` -> convenience mirror path
- `~/.config/codex` -> live applied tree

## Recovery Rules

- Search live config, trash, downloads, and cache evidence for authored source.
- Prefer authored bundles and tracked history over cache-derived reconstruction.
- If cache-only recovery is necessary, clearly mark reconstructed artifacts.
- After recovery, recompare the chezmoi tree, live config, and any external reference repo before declaring success.

## Output Contract

When using this skill, report:

- canonical source path
- mirror/live paths affected
- whether the change is authored config or runtime residue
- any split-brain risk introduced or removed
- any follow-up needed to keep chezmoi authoritative
