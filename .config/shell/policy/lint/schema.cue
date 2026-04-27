package lint

#Tool: {
	present:  bool
	required: bool
	ok:       bool | null

	if required == true {
		present: true
		ok:      true
	}
}

#Observed: {
	schema: "shell.lint.observed.v0"

	tools: {
		shellcheck:  #Tool
		shfmt:       #Tool
		shellharden: #Tool
		bats:        #Tool
		shellspec:   #Tool
	}

	syntax: {
		bash: bool
		zsh:  bool
	}

	tier0: {
		ok: bool
	}
}
