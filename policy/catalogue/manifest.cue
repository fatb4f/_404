package catalogue

import "codex.local/schema"

entries: [...schema.#ManifestEntry]

// Ring-0 install.sh intentionally reads install.manifest instead of parsing CUE.
// This file exists so validate/develop rings can check the manifest shape later.
