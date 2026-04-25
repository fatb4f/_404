package strap

#HostClass: "arch-base" | "debian-base"

#BootstrapStage: "detect" | "env" | "pkgs" | "userland" | "dotfiles" | "chsh" | "doctor"

#HostBootstrap: {
  host: #HostClass
  stages: [...#BootstrapStage]

  runtime: {
    shell: "bash"
    interactive: false
  }

  owns: {
    env: true
    systemPackages: true
    userlandTools: true
    loginShellSwitch: true
  }

  doesNotOwn: {
    zshDotfileGeneration: true
    homeDotfileState: true
  }
}
