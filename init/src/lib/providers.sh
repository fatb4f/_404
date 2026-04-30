#!/usr/bin/env sh
set -eu

provider_install_payload() {
  provider=${DOMAIN_PROVIDER:-domain_local}

  case "$provider" in
    domain_local)
      return 0
      ;;

    host_pkg)
      if command -v apt-get >/dev/null 2>&1; then
        host_packages=${DOMAIN_HOST_PACKAGES_DEBIAN:-${DOMAIN_HOST_PACKAGE_DEBIAN:-${DOMAIN_HOST_PACKAGES:-${DOMAIN_HOST_PACKAGE:-}}}}
      elif command -v pacman >/dev/null 2>&1; then
        host_packages=${DOMAIN_HOST_PACKAGES_ARCH:-${DOMAIN_HOST_PACKAGE_ARCH:-${DOMAIN_HOST_PACKAGES:-${DOMAIN_HOST_PACKAGE:-}}}}
      else
        host_packages=${DOMAIN_HOST_PACKAGES:-${DOMAIN_HOST_PACKAGE:-}}
      fi
      if [ -n "${DOMAIN_BINS:-}" ]; then
        all_present=1
        for bin in $DOMAIN_BINS; do
          if ! command -v "$bin" >/dev/null 2>&1; then
            all_present=0
            break
          fi
        done
        if [ "$all_present" -eq 1 ]; then
          return 0
        fi
      elif [ -n "${DOMAIN_PRIMARY_BIN:-}" ] && command -v "$DOMAIN_PRIMARY_BIN" >/dev/null 2>&1; then
        return 0
      fi

      if [ -n "$host_packages" ]; then
        # shellcheck disable=SC2086
        install_pkg $host_packages
      else
        printf >&2 'missing host command and no DOMAIN_HOST_PACKAGE declared: %s\n' "$DOMAIN_PRIMARY_BIN"
        return 127
      fi
      ;;

    npm_global)
      command -v npm >/dev/null 2>&1 || { printf >&2 'npm required for %s\n' "$DOMAIN_ID"; return 127; }
      if [ -n "${DOMAIN_PRIMARY_BIN:-}" ] && command -v "$DOMAIN_PRIMARY_BIN" >/dev/null 2>&1; then
        return 0
      fi
      [ -n "${DOMAIN_NPM_PACKAGE:-}" ] || { printf >&2 'DOMAIN_NPM_PACKAGE missing for %s\n' "$DOMAIN_ID"; return 64; }
      if [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ]; then
        printf 'would npm install -g --prefix %s %s\n' "$TOOL_PREFIX_HOME" "$DOMAIN_NPM_PACKAGE"
      else
        npm install -g --prefix "$TOOL_PREFIX_HOME" "$DOMAIN_NPM_PACKAGE"
      fi
      ;;

    cargo_binstall)
      command -v cargo >/dev/null 2>&1 || { printf >&2 'cargo required for %s\n' "$DOMAIN_ID"; return 127; }
      command -v cargo-binstall >/dev/null 2>&1 || { printf >&2 'cargo-binstall required for %s\n' "$DOMAIN_ID"; return 127; }
      [ -n "${DOMAIN_CARGO_CRATE:-}" ] || { printf >&2 'DOMAIN_CARGO_CRATE missing for %s\n' "$DOMAIN_ID"; return 64; }
      if [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ]; then
        printf 'would cargo binstall --no-confirm --disable-telemetry --root %s %s\n' "$TOOL_PREFIX_HOME" "$DOMAIN_CARGO_CRATE"
      else
        cargo binstall --no-confirm --disable-telemetry --root "$TOOL_PREFIX_HOME" "$DOMAIN_CARGO_CRATE"
      fi
      ;;

    cargo_install)
      command -v cargo >/dev/null 2>&1 || { printf >&2 'cargo required for %s\n' "$DOMAIN_ID"; return 127; }
      [ -n "${DOMAIN_CARGO_CRATE:-}" ] || { printf >&2 'DOMAIN_CARGO_CRATE missing for %s\n' "$DOMAIN_ID"; return 64; }
      if [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ]; then
        printf 'would cargo install --locked --root %s %s\n' "$TOOL_PREFIX_HOME" "$DOMAIN_CARGO_CRATE"
      else
        cargo install --locked --root "$TOOL_PREFIX_HOME" "$DOMAIN_CARGO_CRATE"
      fi
      ;;

    go_install)
      command -v go >/dev/null 2>&1 || { printf >&2 'go required for %s\n' "$DOMAIN_ID"; return 127; }
      [ -n "${DOMAIN_GO_MODULE:-}" ] || { printf >&2 'DOMAIN_GO_MODULE missing for %s\n' "$DOMAIN_ID"; return 64; }
      if [ "${DOMAIN_DRY_RUN:-0}" -eq 1 ]; then
        printf 'would GOBIN=%s go install %s\n' "$TOOL_PATH_HOME" "$DOMAIN_GO_MODULE"
      else
        GOBIN="$TOOL_PATH_HOME" go install "$DOMAIN_GO_MODULE"
      fi
      ;;

    github_release)
      command -v gh >/dev/null 2>&1 || { printf >&2 'gh required for %s\n' "$DOMAIN_ID"; return 127; }
      if command -v artifact_realize >/dev/null 2>&1; then
        artifact_realize "$DOMAIN_ID"
      else
        printf >&2 'artifact_realize adapter unavailable for %s\n' "$DOMAIN_ID"
        return 127
      fi
      ;;

    *)
      printf >&2 'unknown provider for %s: %s\n' "$DOMAIN_ID" "$provider"
      return 64
      ;;
  esac
}
