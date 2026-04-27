#!/usr/bin/env bash

if [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]]; then
  printf 'ok github token already present\n'
  return 0
fi

if ! command -v gh >/dev/null 2>&1; then
  printf 'warn gh not available, skipping token export\n'
  return 0
fi

token="$(gh auth token 2>/dev/null || true)"
if [[ -n "$token" ]]; then
  export GITHUB_TOKEN="$token"
  printf 'ok github token exported from gh auth token\n'
else
  printf 'warn gh auth token unavailable\n'
fi
