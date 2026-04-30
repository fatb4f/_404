#!/usr/bin/env bash
json_bool() { case "$1" in true|false) printf '%s' "$1" ;; *) return 64 ;; esac; }
