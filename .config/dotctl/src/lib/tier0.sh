#!/usr/bin/env bash
# shellcheck shell=bash

dotctl_tier0_repo_root() {
  if [[ -n "${DOTCTL_TIER0_REPO_ROOT:-}" ]]; then
    printf '%s\n' "$DOTCTL_TIER0_REPO_ROOT"
    return 0
  fi

  if [[ -d "${XDG_DATA_HOME:-$HOME/.local/share}/testspec/tier-0/tests/tier0" ]]; then
    printf '%s/testspec\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
    return 0
  fi

  if git -C "${PWD:-.}" rev-parse --show-toplevel >/dev/null 2>&1; then
    local git_root
    git_root="$(git -C "${PWD:-.}" rev-parse --show-toplevel)"
    if [[ -d "$git_root/tier-0/tests/tier0" ]]; then
      printf '%s\n' "$git_root"
      return 0
    fi
  fi

  if [[ -d "${PWD:-.}/tier-0/tests/tier0" ]]; then
    printf '%s\n' "${PWD:-.}"
    return 0
  fi

  printf '%s/testspec\n' "${XDG_DATA_HOME:-$HOME/.local/share}"
}

dotctl_tier0_harness_root() {
  local repo_root="${1:?repo root}"
  printf '%s/tier-0/tests/tier0\n' "$repo_root"
}

dotctl_tier0_state_root() {
  printf '%s/dotctl/tier0/robustness\n' "${XDG_STATE_HOME:-$HOME/.local/state}"
}

dotctl_tier0_default_report_dir() {
  local repo_root="${1:?repo root}"
  printf '%s/.tier0-results\n' "$repo_root"
}

dotctl_tier0_report_files() {
  local dir="${1:?dir}"
  find "$dir" -maxdepth 1 -type f \( -name 'tier0-robustness-*.json' -o -name 'tier0-matrix-summary.json' \) | sort
}

dotctl_tier0_copy_reports() {
  local source_dir="${1:?source_dir}"
  local dest_dir="${2:?dest_dir}"
  local file

  mkdir -p "$dest_dir"
  for file in $(dotctl_tier0_report_files "$source_dir"); do
    cp -a -- "$file" "$dest_dir/$(basename -- "$file")"
  done
}

dotctl_tier0_collect_result_json() {
  local backend="${1:?backend}"
  local report_dir="${2:?report_dir}"
  local state_root="${3:?state_root}"
  local result_source="$report_dir"

  if [[ ! -d "$result_source" || -z "$(dotctl_tier0_report_files "$result_source" 2>/dev/null | head -n1)" ]]; then
    result_source="$state_root"
  fi

  if [[ "$backend" == matrix ]]; then
    jq -n \
      --arg backend "$backend" \
      --arg state_root "$state_root" \
      --arg report_dir "$report_dir" \
      --slurpfile summary "$report_dir/tier0-matrix-summary.json" \
      '{
        ok: ($summary[0].ok // false),
        backend: $backend,
        schema_ok: (($summary[0].distros.debian.schema_result // "fail") == "pass" and ($summary[0].distros.arch.schema_result // "fail") == "pass"),
        success_ok: (($summary[0].distros.debian.success_result // "fail") == "pass" and ($summary[0].distros.arch.success_result // "fail") == "pass"),
        state_root: $state_root,
        report_dir: $report_dir,
        reports: [
          {
            distro: "debian",
            path: $summary[0].distros.debian.report.json,
            schema_ok: (($summary[0].distros.debian.schema_result // "fail") == "pass"),
            success_ok: (($summary[0].distros.debian.success_result // "fail") == "pass")
          },
          {
            distro: "arch",
            path: $summary[0].distros.arch.report.json,
            schema_ok: (($summary[0].distros.arch.schema_result // "fail") == "pass"),
            success_ok: (($summary[0].distros.arch.success_result // "fail") == "pass")
          }
        ]
      }'
    return 0
  fi

  local reports=()
  local file
  while IFS= read -r file; do
    reports+=("$file")
  done < <(dotctl_tier0_report_files "$result_source" 2>/dev/null || true)

  if ((${#reports[@]} == 0)); then
    jq -n --arg backend "$backend" --arg state_root "$state_root" --arg report_dir "$report_dir" '{
      ok: false,
      backend: $backend,
      schema_ok: false,
      success_ok: false,
      state_root: $state_root,
      report_dir: $report_dir,
      reports: []
    }'
    return 0
  fi

  local reports_json
  reports_json="$(
    for file in "${reports[@]}"; do
      jq -c --arg path "$file" '
        {
          distro: (.distro // null),
          path: $path,
          schema_ok: (.schema_ok // false),
          success_ok: (.success_ok // false)
        }
      ' "$file"
    done | jq -s '.'
  )"

  jq -n \
    --arg backend "$backend" \
    --arg state_root "$state_root" \
    --arg report_dir "$report_dir" \
    --argjson reports "$reports_json" \
    '{
      ok: (all($reports[]; (.schema_ok // false) and (.success_ok // false))),
      backend: $backend,
      schema_ok: (all($reports[]; (.schema_ok // false))),
      success_ok: (all($reports[]; (.success_ok // false))),
      state_root: $state_root,
      report_dir: $report_dir,
      reports: $reports
    }'
}

dotctl_tier0_run() {
  local backend="${1:-matrix}"
  local strict="${2:-true}"
  local json="${3:-false}"
  local report_dir="${4:-}"
  local repo_root state_root harness_root default_report_dir status=0
  local result_json=""

  repo_root="$(dotctl_tier0_repo_root)"
  state_root="$(dotctl_tier0_state_root)"
  harness_root="$(dotctl_tier0_harness_root "$repo_root")"
  default_report_dir="$(dotctl_tier0_default_report_dir "$repo_root")"
  report_dir="${report_dir:-$default_report_dir}"

  if [[ "$json" == true ]]; then
    local out_file err_file
    out_file="$(mktemp)"
    err_file="$(mktemp)"
    set +e
    case "$backend" in
      matrix)
        TIER0_STRICT="$strict" \
        TIER0_REPORT_DIR="$report_dir" \
        bash "$harness_root/scripts/distrobox-matrix.sh" >"$out_file" 2>"$err_file"
        status=$?
        ;;
      headless)
        TIER0_STRICT="$strict" \
        bash "$harness_root/run.sh" --all --repo "$repo_root" >"$out_file" 2>"$err_file"
        status=$?
        dotctl_tier0_copy_reports "$state_root" "$report_dir"
        ;;
      kitty-run-shell)
        TIER0_STRICT="$strict" \
        TIER0_BACKEND="kitty-run-shell" \
        bash "$harness_root/run.sh" --all --repo "$repo_root" >"$out_file" 2>"$err_file"
        status=$?
        dotctl_tier0_copy_reports "$state_root" "$report_dir"
        ;;
      *)
        printf 'unsupported backend: %s\n' "$backend" >&2
        rm -f -- "$out_file" "$err_file"
        return 64
        ;;
    esac
    set -e
  else
    case "$backend" in
      matrix)
        TIER0_STRICT="$strict" \
        TIER0_REPORT_DIR="$report_dir" \
        bash "$harness_root/scripts/distrobox-matrix.sh"
        status=$?
        ;;
      headless)
        TIER0_STRICT="$strict" \
        bash "$harness_root/run.sh" --all --repo "$repo_root"
        status=$?
        dotctl_tier0_copy_reports "$state_root" "$report_dir"
        ;;
      kitty-run-shell)
        TIER0_STRICT="$strict" \
        TIER0_BACKEND="kitty-run-shell" \
        bash "$harness_root/run.sh" --all --repo "$repo_root"
        status=$?
        dotctl_tier0_copy_reports "$state_root" "$report_dir"
        ;;
      *)
        printf 'unsupported backend: %s\n' "$backend" >&2
        return 64
        ;;
    esac
  fi

  if [[ "$json" == true ]]; then
    result_json="$(dotctl_tier0_collect_result_json "$backend" "$report_dir" "$state_root")"
    printf '%s\n' "$result_json"
  fi

  return "$status"
}
