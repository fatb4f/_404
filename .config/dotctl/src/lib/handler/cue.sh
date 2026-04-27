# shellcheck shell=bash

dotctl_cue_vet() {
  local policy="${1:?missing cue policy}"
  local input="${2:?missing cue input}"
  local def="${3:?missing cue definition}"

  command -v cue >/dev/null 2>&1 || {
    printf 'missing required command: cue\n' >&2
    return 1
  }

  cue vet "$policy" "$input" -d "$def"
}

dotctl_cue_export_json() {
  local path="${1:?missing cue file}"
  local expr="${2:?missing cue expression}"

  command -v cue >/dev/null 2>&1 || {
    printf 'missing required command: cue\n' >&2
    return 1
  }

  cue export "$path" -e "$expr" --out json
}
