package dotctl

#RelPath: =~"^[^/].*"

#Backend: {
	kind:       "git"
	isWorktree: true
	repo:       string
	worktree:   string
}

#Refs: {
	branch:   string
	upstream: string | null
	head:     string
	ahead:    int & >=0
	behind:   int & >=0
}

#Paths: {
	tracked:   [...#RelPath]
	dirty:     [...#RelPath]
	untracked: [...#RelPath]
	deleted:   [...#RelPath]
	ignored:   [...#RelPath]
}

#GitSubstrate: {
	schema: "dotctl.git.substrate.observed.v0"

	backend: #Backend
	refs:    #Refs
	paths:   #Paths

	generated: {
		".config/dotctl/dotctl":     false
		".config/dotctl/bin/dotctl": false
	}

	syntax_failures: {}

	_generatedTracked: [
		for p in paths.tracked
		if p == ".config/dotctl/dotctl" || p == ".config/dotctl/bin/dotctl" {
			p
		},
	]
	_generatedTracked: []
}

#GitAddPlan: {
	schema: "dotctl.git.add.plan.v0"
	operation: "add"

	observed: #GitSubstrate

	requested_targets: [...#RelPath]
	resolved_targets: [...#RelPath]
}
