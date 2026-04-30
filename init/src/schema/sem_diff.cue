package schema

// Semantic diff evidence contract.
// The wrapper owns the JSON envelope; sem remains the evidence generator.

#SemanticDiff: {
	schema: "dev.semantic_diff.v1"

	tool: {
		name: "sem"
		path: =~"^/"
		version?: string
	}

	input: {
		source: "git diff --cached"
		head: =~"^[0-9a-f]{7,40}$"
		branch?: string
	}

	status: "pass" | "warn"

	raw: _
}
