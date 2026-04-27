package dotctl

#Command: {
  path: string
  exists: bool
  thin: bool
  line_count: int & >=0
}

#Lib: {
  path: string
  exists: bool
}

#Substrate: {
  schema: "dotctl.substrate.observed.v0"

  commands: {
    audit: {
      observe: #Command & {
        path:      ".config/dotctl/src/audit_observe_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
      vet: #Command & {
        path:      ".config/dotctl/src/audit_vet_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
      run: #Command & {
        path:      ".config/dotctl/src/audit_run_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
    }
    git: {
      observe: #Command & {
        path:      ".config/dotctl/src/git_observe_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
      vet: #Command & {
        path:      ".config/dotctl/src/git_vet_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
      project_state: #Command & {
        path:      ".config/dotctl/src/git_project_state_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
      refresh: #Command & {
        path:      ".config/dotctl/src/git_refresh_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
      status: #Command & {
        path:      ".config/dotctl/src/git_status_command.sh"
        exists:    true
        thin:      true
        line_count: <=6
      }
    }
    check: #Command & {
      path:      ".config/dotctl/src/check_command.sh"
      exists:    true
      thin:      true
      line_count: <=6
    }
    status: #Command & {
      path:      ".config/dotctl/src/status_command.sh"
      exists:    true
      thin:      true
      line_count: <=6
    }
    bootstrap: #Command & {
      path:      ".config/dotctl/src/bootstrap_command.sh"
      exists:    true
    }
    provision: #Command & {
      path:      ".config/dotctl/src/provision_command.sh"
      exists:    true
    }
  }

  libs: {
    env: #Lib & {
      path:   ".config/dotctl/src/lib/env.sh"
      exists: true
    }
    audit: #Lib & {
      path:   ".config/dotctl/src/lib/audit.sh"
      exists: true
    }
    git: #Lib & {
      path:   ".config/dotctl/src/lib/git.sh"
      exists: true
    }
    check: #Lib & {
      path:   ".config/dotctl/src/lib/check.sh"
      exists: true
    }
    yadm: #Lib & {
      path:   ".config/dotctl/src/lib/yadm.sh"
      exists: true
    }
  }

  generated: {
    ".config/dotctl/dotctl": false
    ".config/dotctl/bin/dotctl": false
  }

  syntax_failures: {}
}
