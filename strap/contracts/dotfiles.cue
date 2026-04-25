package strap

#DotfilesAuthority: {
  manager: "yadm" | "bare-git"
  workTree: "HOME"
  sourceTransform: false
  ownsZshConfig: true
  chshAfterLive: true
  forbiddenPrefixes: ["dot_", "executable_", "readonly_", "empty_"]
}
