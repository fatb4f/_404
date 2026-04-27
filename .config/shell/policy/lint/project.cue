package lint

#ShellLintGate: #Observed & {
	tools: {
		shellcheck: required: policy.requiredTools.shellcheck
		shfmt:      required: policy.requiredTools.shfmt

		shellharden: required: policy.requiredTools.shellharden
		bats:        required: policy.requiredTools.bats
		shellspec:   required: policy.requiredTools.shellspec
	}

	syntax: {
		bash: true
		zsh:  true
	}

	tier0: {
		ok: true
	}
}
