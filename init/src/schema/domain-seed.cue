package schema

#Ring: "substrate" | "workflow" | "terminal" | "editor" | "agent"
#Provider: "host_pkg" | "npm_global" | "cargo_binstall" | "cargo_install" | "go_install" | "github_release" | "ruby_gem" | "domain_local"
#Severity: "fatal" | "degraded" | "warning"
#Mode: =~"^[0-7]{3,4}$"

#Roots: {
	dots_repo:  string | *"src"
	dots_dir:   string | *"dots"
	dots:       string | *"$HOME/$DOTS_REPO/$DOTS_DIR"
	xdg_config: string | *"$DOTS_HOME/.config"
	xdg_data:   string | *"$DOTS_HOME/.local/share"
	xdg_opt:    string | *"$DOTS_HOME/.local/opt"
	xdg_state:  string | *"$HOME/.local/state"
	xdg_cache:  string | *"$HOME/.cache"
	tool_path:  string | *"$HOME/.local/bin"
}

#FileSpec: {
	source: string
	target: string
	mode:   #Mode | *"0644"
}

#CopySpec: {
	src:  string
	dst:  string
	mode: #Mode | *"0644"
}

#LinkSpec: {
	source: string
	target: string
}

#CheckSpec: {
	id:       string
	command:  string
	severity: #Severity | *"degraded"
}

#DomainSeed: {
	id:        string
	namespace: string
	stage:     string
	ring:      #Ring
	provider:  #Provider
	output_dir?: string
	template_override?: string
	bins: [...string]
	requires?: [...string]
	provides?: [...string]
	extra_env?: [string]: string
	init_sources?: [...string]
	source?: {
		npm?: {
			package: string
			version?: string | *"latest"
		}
		cargo?: {
			crate: string
			version?: string | *"latest"
			locked?: bool | *true
		}
		go?: {
			module: string
			version: string | *"latest"
		}
		github?: {
			repo: string
			ref?: string | *"latest"
			asset: string
			stripComponents?: int | *1
		}
	}
	files: [...#FileSpec]
	copies?: [...#CopySpec]
	links?: [...#LinkSpec]
	checks: [...#CheckSpec]
}

#Seed: {
	roots: #Roots
	domains: [...#DomainSeed]
}
