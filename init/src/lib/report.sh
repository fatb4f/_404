#!/usr/bin/env sh
set -eu

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g; s/	/\\t/g'
}

emit_check() {
  domain=$1; id=$2; ok=$3; class=$4; reason=$5
  printf '{"domain":"%s","check":"%s","ok":%s,"class":"%s","reason":"%s"}\n' \
    "$(json_escape "$domain")" \
    "$(json_escape "$id")" \
    "$ok" \
    "$(json_escape "$class")" \
    "$(json_escape "$reason")"
}

emit_event() {
  domain=$1; event=$2; reason=$3
  printf '{"domain":"%s","event":"%s","reason":"%s"}\n' \
    "$(json_escape "$domain")" \
    "$(json_escape "$event")" \
    "$(json_escape "$reason")"
}
