package schema

// Guarded commit status contract.
// The wrapper owns the JSON envelope; shell only writes the evidence file.

#CheckStatus: {
	schema: "dev.check_status.v1"

	decision: {
		commit_allowed: bool
		push_allowed: bool
		reason?: string
	}

	checks?: [...{
		id: string
		status: "pass" | "warn" | "fail"
		message?: string
	}]

	raw: _
}
