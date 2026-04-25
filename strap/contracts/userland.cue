package strap

#InstallStrategy: "bin" | "opt"

#UserlandArtifact: {
  name: =~"^[a-zA-Z0-9._-]+$"
  repo: =~"^[^/[:space:]]+/[^/[:space:]]+$"

  // GitHub release asset glob passed directly to:
  //   gh release download -R <repo> --pattern <pkg>
  pkg: =~"^[^[:space:]]+$"

  install: #InstallStrategy | *"bin"
  opt?: =~"^[a-zA-Z0-9._-]+$"
  bins: [...=~"^[^/[:space:]]+$"]
  enabled?: bool | *true
}

#UserlandInstall: {
  selector: "jq -c '.artifacts[] | select((.enabled // true) == true)'"
  downloader: "gh release download -R $repo --pattern $pkg"
  binDir: string | *"$HOME/.local/bin"
  optDir: string | *"$HOME/.local/opt"
  artifacts: [...#UserlandArtifact]
}
