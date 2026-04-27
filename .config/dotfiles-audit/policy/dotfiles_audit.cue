package dotfiles

#Family: "bin" | "broot" | "nvim" | "uv"

#Kind: "file" | "dir" | "symlink" | "other"

#Bucket:
	"tracked-clean" |
	"tracked-identity-path" |
	"tracked-generated-state" |
	"untracked-real-config" |
	"untracked-generated-state" |
	"broken-syntax"

#Syntax: {
	checked: bool
	ok:      bool | null
	tool:    string | null
}

#Record: {
	path: =~"^\\.config/(bin|broot|nvim|uv)(/|$)"

	family: #Family
	kind:   #Kind

	tracked: bool

	yadm_status: string | null

	identity_hit:        bool
	generated_candidate: bool

	syntax: #Syntax

	bucket: #Bucket

	if syntax.checked == true && syntax.ok == false {
		bucket: "broken-syntax"
	}

	if !(syntax.checked == true && syntax.ok == false) && tracked == true && identity_hit == true {
		bucket: "tracked-identity-path"
	}

	if !(syntax.checked == true && syntax.ok == false) && tracked == true && identity_hit == false && generated_candidate == true {
		bucket: "tracked-generated-state"
	}

	if !(syntax.checked == true && syntax.ok == false) && tracked == true && identity_hit == false && generated_candidate == false {
		bucket: "tracked-clean"
	}

	if !(syntax.checked == true && syntax.ok == false) && tracked == false && generated_candidate == true {
		bucket: "untracked-generated-state"
	}

	if !(syntax.checked == true && syntax.ok == false) && tracked == false && generated_candidate == false {
		bucket: "untracked-real-config"
	}
}

#Audit: {
	schema: "dotfiles.audit.v0"
	mode:   "inventory-only"

	home: string

	targets: [...=~"^\\.config/(bin|broot|nvim|uv)$"]

	records: [...#Record]

	// Hard gate for this boundary.
	_brokenSyntax: [
		for r in records
		if r.bucket == "broken-syntax" {
			r.path
		},
	]
	_brokenSyntax: []

	// Warning buckets for now. Harden later by requiring [].
	_trackedIdentityPaths: [
		for r in records
		if r.bucket == "tracked-identity-path" {
			r.path
		},
	]

	_trackedGeneratedState: [
		for r in records
		if r.bucket == "tracked-generated-state" {
			r.path
		},
	]
}
