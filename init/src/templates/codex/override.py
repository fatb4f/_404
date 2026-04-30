from __future__ import annotations

from typing import Any


def project(fragment: dict[str, Any]) -> dict[str, Any]:
    """Return Codex-specific projection patches for the generator.

    The generator applies the returned patch to the domain fragment and the
    generated template map. This keeps Codex specialization outside
    init/src/gen/domain.py.
    """

    codex_profile = fragment.get("codex_profile") or {}
    profile = codex_profile.get("profile", "slim")

    return {
        "generated_files_remove": [
            "src/templates/domain/files/env.sh.tmpl",
            "src/templates/domain/files/init.sh.tmpl",
            "src/templates/codex/files/hooks/session-snapshot.tmpl",
            "src/templates/codex/files/hooks/pre-tool-use.tmpl",
            "src/templates/codex/files/hooks/post-tool-use.tmpl",
            "src/templates/codex/files/rules/README.md.tmpl",
        ],
        "generated_files_add": {
            "src/templates/codex/files/config.toml.tmpl": "files/config.toml",
            "src/templates/codex/files/AGENTS.md.tmpl": "files/AGENTS.md",
            "src/templates/codex/files/hooks/session-init.sh.tmpl": "files/hooks/session-init.sh",
            "src/templates/codex/files/hooks/pre-tool-use.sh.tmpl": "files/hooks/pre-tool-use.sh",
            "src/templates/codex/files/hooks/post-tool-use.sh.tmpl": "files/hooks/post-tool-use.sh",
            "src/templates/codex/files/hooks/stop.sh.tmpl": "files/hooks/stop.sh",
            "src/templates/codex/files/roles/projection-maintainer.md.tmpl": "files/roles/projection-maintainer.md",
            "src/templates/codex/files/roles/reviewer.md.tmpl": "files/roles/reviewer.md",
            "src/templates/codex/files/roles/implementer.md.tmpl": "files/roles/implementer.md",
            "src/templates/codex/files/roles/release-checker.md.tmpl": "files/roles/release-checker.md",
            "src/templates/codex/files/skills/cue/SKILL.md.tmpl": "files/skills/cue/SKILL.md",
            "src/templates/codex/files/bin/_404-codex.tmpl": "files/bin/_404-codex",
        },
        "files_remove": [
            "files/hooks/session-snapshot",
            "files/hooks/pre-tool-use",
            "files/hooks/post-tool-use",
            "files/rules/README.md",
        ],
        "files_add": [
            {"source": "files/config.toml", "target": "$XDG_CONFIG_HOME/codex/config.toml", "mode": "0644"},
            {"source": "files/AGENTS.md", "target": "$XDG_CONFIG_HOME/codex/AGENTS.md", "mode": "0644"},
            {
                "source": "files/hooks/session-init.sh",
                "target": "$XDG_CONFIG_HOME/codex/hooks/session-init.sh",
                "mode": "0755",
            },
            {
                "source": "files/hooks/pre-tool-use.sh",
                "target": "$XDG_CONFIG_HOME/codex/hooks/pre-tool-use.sh",
                "mode": "0755",
            },
            {
                "source": "files/hooks/post-tool-use.sh",
                "target": "$XDG_CONFIG_HOME/codex/hooks/post-tool-use.sh",
                "mode": "0755",
            },
            {"source": "files/hooks/stop.sh", "target": "$XDG_CONFIG_HOME/codex/hooks/stop.sh", "mode": "0755"},
            {
                "source": "files/roles/projection-maintainer.md",
                "target": "$XDG_CONFIG_HOME/codex/roles/projection-maintainer.md",
                "mode": "0644",
            },
            {"source": "files/roles/reviewer.md", "target": "$XDG_CONFIG_HOME/codex/roles/reviewer.md", "mode": "0644"},
            {"source": "files/roles/implementer.md", "target": "$XDG_CONFIG_HOME/codex/roles/implementer.md", "mode": "0644"},
            {
                "source": "files/roles/release-checker.md",
                "target": "$XDG_CONFIG_HOME/codex/roles/release-checker.md",
                "mode": "0644",
            },
            {"source": "files/skills/cue/SKILL.md", "target": "$XDG_CONFIG_HOME/codex/skills/cue/SKILL.md", "mode": "0644"},
            {"source": "files/bin/_404-codex", "target": "$DOMAIN_PREFIX/bin/_404-codex", "mode": "0755"},
        ],
        "checks_remove": [
            "hooks-present",
            "hook-shell-parse",
        ],
        "checks_add": [
            {
                "id": "agents-present",
                "command": "test -f $XDG_CONFIG_HOME/codex/AGENTS.md",
                "severity": "fatal",
            },
            {
                "id": "hooks-present",
                "command": "test -x $XDG_CONFIG_HOME/codex/hooks/session-init.sh && test -x $XDG_CONFIG_HOME/codex/hooks/pre-tool-use.sh && test -x $XDG_CONFIG_HOME/codex/hooks/post-tool-use.sh && test -x $XDG_CONFIG_HOME/codex/hooks/stop.sh",
                "severity": "fatal",
            },
            {
                "id": "roles-present",
                "command": "test -f $XDG_CONFIG_HOME/codex/roles/projection-maintainer.md && test -f $XDG_CONFIG_HOME/codex/roles/reviewer.md && test -f $XDG_CONFIG_HOME/codex/roles/implementer.md && test -f $XDG_CONFIG_HOME/codex/roles/release-checker.md",
                "severity": "fatal",
            },
            {
                "id": "skill-present",
                "command": "test -f $XDG_CONFIG_HOME/codex/skills/cue/SKILL.md",
                "severity": "fatal",
            },
            {
                "id": "config-present",
                "command": "test -f $XDG_CONFIG_HOME/codex/config.toml",
                "severity": "fatal",
            },
            {
                "id": "launcher-present",
                "command": "test -x $DOMAIN_PREFIX/bin/_404-codex",
                "severity": "fatal",
            },
            {
                "id": "toml-parse",
                "command": "python3 -c 'import os,pathlib,tomllib; tomllib.loads(pathlib.Path(os.environ[\"XDG_CONFIG_HOME\"] + \"/codex/config.toml\").read_text())'",
                "severity": "fatal",
            },
            {
                "id": "hook-shell-parse",
                "command": "sh -n $XDG_CONFIG_HOME/codex/hooks/session-init.sh $XDG_CONFIG_HOME/codex/hooks/pre-tool-use.sh $XDG_CONFIG_HOME/codex/hooks/post-tool-use.sh $XDG_CONFIG_HOME/codex/hooks/stop.sh $DOMAIN_PREFIX/bin/_404-codex",
                "severity": "fatal",
            },
        ],
        "cleanup_outputs": [
            "files/env.sh",
            "files/init.sh",
            "files/hooks/session-snapshot",
            "files/hooks/pre-tool-use",
            "files/hooks/post-tool-use",
            "files/hooks/shell-tool",
            "files/hooks/shell_snapshot",
            "files/hooks/function",
            "files/rules/README.md",
        ],
        "template_values": {
            "CODEX_PROFILE": profile,
            "CODEX_CONFIG_TARGET": codex_profile.get("config_target", "$XDG_CONFIG_HOME/codex/config.toml"),
            "CODEX_HOOKS_TARGET": codex_profile.get("hooks_target", "$XDG_CONFIG_HOME/codex/hooks"),
            "CODEX_AGENTS_TARGET": "$XDG_CONFIG_HOME/codex/AGENTS.md",
            "CODEX_ROLES_TARGET": "$XDG_CONFIG_HOME/codex/roles",
            "CODEX_SKILLS_TARGET": codex_profile.get("skills_target", "$XDG_CONFIG_HOME/codex/skills"),
        },
    }
