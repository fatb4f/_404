package schema

// Codex profile projection contract.
// Authority belongs here; shell scripts only adapt runtime hook IO.

#CodexProfileName: =~"^[a-z][a-z0-9_-]*$"

#CodexApprovalPolicy:
    "untrusted" |
    "on-request" |
    "never" |
    {
        granular: {
            mcp_elicitations?: bool
            request_permissions?: bool
            rules?: bool
            sandbox_approval?: bool
            skill_approval?: bool
        }
    }

#CodexSandboxMode: "read-only" | "workspace-write" | "danger-full-access"
#CodexWebSearchMode: "disabled" | "cached" | "live"

#CodexShellEnvironmentPolicy: {
    inherit: *"core" | "all" | "none"
    include_only?: [...string]
    exclude?: [...string]
    set?: [string]: string
    experimental_use_profile?: bool | *false
    ignore_default_excludes?: bool | *false
}

#CodexFrameName: "session-frame" | "context-frame" | "repo-frame"
#CodexRoleName:
    "projection-maintainer" |
    "reviewer" |
    "implementer" |
    "release-checker"

#CodexFeatureSet: {
    codex_hooks: *true | bool
    shell_tool: *true | bool
    shell_snapshot: *true | bool
}

#CodexHookEvent:
    "SessionStart" |
    "PreToolUse" |
    "PostToolUse" |
    "PermissionRequest" |
    "UserPromptSubmit" |
    "Stop"

#CodexHookCommand: {
    type: "command"
    command: string
    timeout?: int & >=1 & <=600
    statusMessage?: string
}

#CodexHookGroup: {
    matcher?: string
    hooks: [...#CodexHookCommand]
}

#CodexHooks: {
    SessionStart?: [...#CodexHookGroup]
    PreToolUse?: [...#CodexHookGroup]
    PostToolUse?: [...#CodexHookGroup]
    PermissionRequest?: [...#CodexHookGroup]
    UserPromptSubmit?: [...#CodexHookGroup]
    Stop?: [...#CodexHookGroup]
}

#CodexProfile: {
    name: #CodexProfileName
    approval_policy: #CodexApprovalPolicy
    sandbox_mode: #CodexSandboxMode
    web_search?: #CodexWebSearchMode
    shell_environment_policy?: #CodexShellEnvironmentPolicy
}

#CodexProjection: {
    // This repo keeps Codex config under the dotfile tree. Runtime launchers
    // set CODEX_HOME to this directory so Codex resolves config.toml here.
    configTarget: *"$XDG_CONFIG_HOME/codex/config.toml" | string
    hooksTarget:  *"$XDG_CONFIG_HOME/codex/hooks" | string
    rulesTarget:  *"$XDG_CONFIG_HOME/codex/rules" | string
    skillsTarget: *"$XDG_CONFIG_HOME/codex/skills" | string
    frames?: [...#CodexFrameName]
    roles?: [...#CodexRoleName]

    profile: #CodexProfileName
    features: #CodexFeatureSet
    profiles: [#CodexProfileName]: #CodexProfile
    hooks?: #CodexHooks
}
