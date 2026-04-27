package lint

policy: {
	requiredTools: {
		shellcheck: true
		shfmt:      true

		shellharden: true
		bats:        true
		shellspec:   true
	}
}
