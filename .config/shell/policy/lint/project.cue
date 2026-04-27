package lint

#ShellLintGate: #Observed & {
	tools: {
		shellcheck: {
			if policy.requiredTools.shellcheck == true {
				present: true
				ok:      true
			}
		}
		shfmt: {
			if policy.requiredTools.shfmt == true {
				present: true
				ok:      true
			}
		}

		shellharden: {
			if policy.requiredTools.shellharden == true {
				present: true
				ok:      true
			}
		}
		bats: {
			if policy.requiredTools.bats == true {
				present: true
				ok:      true
			}
		}
		shellspec: {
			if policy.requiredTools.shellspec == true {
				present: true
				ok:      true
			}
		}
	}

	syntax: {
		bash: true
		zsh:  true
	}

	tier0: {
		ok: true
	}
}
