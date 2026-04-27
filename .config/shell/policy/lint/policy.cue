package lint

policy: {
	requiredTools: {
		shellcheck: true
		shfmt:      true

		// Promote later after managed install exists.
		shellharden: false
		bats:        false
		shellspec:   false
	}
}
