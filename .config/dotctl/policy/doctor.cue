package dotctl

#DoctorService: {
  dependsOn: [...string]
  severity: "critical" | "degraded" | "warning"
  status: "ok" | "missing" | "warning" | "degraded"
  message: string
}

#Doctor: {
  schema: "dotctl.doctor.observed.v0"

  services: {
    "terminal.kitty": #DoctorService & {
      dependsOn: []
      severity: "degraded"
    }
    "host.loginctl": #DoctorService & {
      dependsOn: []
      severity: "degraded"
    }
    "host.xdg-runtime": #DoctorService & {
      dependsOn: []
      severity: "critical"
    }
    "display.env": #DoctorService & {
      dependsOn: []
      severity: "warning"
    }
    "display.wayland": #DoctorService & {
      dependsOn: ["host.xdg-runtime", "display.env"]
      severity: "warning"
    }
    "display.x11": #DoctorService & {
      dependsOn: ["display.env"]
      severity: "warning"
    }
    "network.link": #DoctorService & {
      dependsOn: []
      severity: "degraded"
    }
    "network.route": #DoctorService & {
      dependsOn: ["network.link"]
      severity: "critical"
    }
    "network.dns": #DoctorService & {
      dependsOn: ["network.route"]
      severity: "critical"
    }
    "service.dbus-session": #DoctorService & {
      dependsOn: ["host.xdg-runtime"]
      severity: "degraded"
    }
    "service.systemd-user": #DoctorService & {
      dependsOn: ["host.loginctl"]
      severity: "degraded"
    }
    "shell.env": #DoctorService & {
      dependsOn: []
      severity: "critical"
    }
    "shell.path": #DoctorService & {
      dependsOn: ["shell.env"]
      severity: "critical"
    }
    "terminal.kitty-session": #DoctorService & {
      dependsOn: ["terminal.kitty", "shell.env"]
      severity: "warning"
    }
    "tool.dotctl": #DoctorService & {
      dependsOn: ["shell.path"]
      severity: "critical"
    }
    "tool.cue": #DoctorService & {
      dependsOn: ["shell.path"]
      severity: "critical"
    }
    "tool.just": #DoctorService & {
      dependsOn: ["shell.path"]
      severity: "critical"
    }
    "backend.yadm": #DoctorService & {
      dependsOn: ["shell.path"]
      severity: "critical"
    }
    "tier0.shell": #DoctorService & {
      dependsOn: ["shell.env"]
      severity: "critical"
    }
    "policy.audit": #DoctorService & {
      dependsOn: ["tool.dotctl", "tool.cue", "backend.yadm"]
      severity: "critical"
    }
    "precommit.shell-lint": #DoctorService & {
      dependsOn: ["tool.cue", "tool.just", "tier0.shell"]
      severity: "critical"
    }
  }
}
