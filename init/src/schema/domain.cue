package schema

#Ring:     "substrate" | "workflow" | "terminal" | "editor" | "agent"
#Provider: "host_pkg" | "npm_global" | "cargo_binstall" | "cargo_install" | "go_install" | "github_release" | "ruby_gem" | "domain_local"
#Severity: "fatal" | "degraded" | "warning"
#Activation: "atomic-copy" | "symlink" | "wrapper" | "none"

#OwnedPath: {
	id: string
	source?: string
	target: string
	mode?: =~"^[0-7]{3,4}$"
	activation: #Activation
	role: "authored" | "projected" | "payload" | "activated" | "state" | "cache"
	tracked: bool | *false
	mutableByApp: bool | *false
	secret: bool | *false
}

#Check: {
	id: string
	command: string
	severity: #Severity
	provides?: [...string]
}

#Domain: {
	id: string
	namespace: string
	stage: string
	ring: #Ring
	provider: #Provider
	outputDir?: string
	requires?: [...string]
	provides: [...string]
	roots: [string]: string
	paths: [string]: string
	owns: [...#OwnedPath]
	checks: [...#Check]
}
