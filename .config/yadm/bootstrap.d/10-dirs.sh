#!/usr/bin/env bash

detect_host_class() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    local id_like=" ${ID_LIKE:-} "
    local id="${ID:-}"

    case "$id" in
      arch|artix|endeavouros|manjaro)
        printf 'arch-base\n'
        return 0
        ;;
      debian|ubuntu|linuxmint|pop)
        printf 'debian-base\n'
        return 0
        ;;
    esac

    case "$id_like" in
      *' arch '*)
        printf 'arch-base\n'
        return 0
        ;;
      *' debian '*|*' ubuntu '*)
        printf 'debian-base\n'
        return 0
        ;;
    esac
  fi

  if have pacman; then
    printf 'arch-base\n'
    return 0
  fi

  if have apt-get; then
    printf 'debian-base\n'
    return 0
  fi

  printf 'unsupported\n'
  return 1
}

install_arch_packages() {
  local packages=()
  local file pkg

  for file in "$BOOTSTRAP_PKG_DIR/arch-base.pkgs"; do
    [[ -r "$file" ]] || continue
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
      pkg=${pkg%%#*}
      pkg=${pkg//[$'\t\r\n ']}
      [[ -n "$pkg" ]] || continue
      packages+=("$pkg")
    done < "$file"
  done

  ((${#packages[@]})) || return 0

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n pacman -Sy\n'
  else
    sudo -n pacman -Sy
  fi

  local resolved=()
  for pkg in "${packages[@]}"; do
    if ! pacman -Si "$pkg" >/dev/null 2>&1; then
      die "arch-base package does not resolve: $pkg"
    fi
    resolved+=("$pkg")
  done

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n pacman -Syu --needed --noconfirm'
    printf ' %q' "${resolved[@]}"
    printf '\n'
    return 0
  fi

  sudo -n pacman -Syu --needed --noconfirm "${resolved[@]}"
}

install_debian_packages() {
  local packages=()
  local file pkg

  for file in "$BOOTSTRAP_PKG_DIR/debian-base.pkgs"; do
    [[ -r "$file" ]] || continue
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
      pkg=${pkg%%#*}
      pkg=${pkg//[$'\t\r\n ']}
      [[ -n "$pkg" ]] || continue
      packages+=("$pkg")
    done < "$file"
  done

  ((${#packages[@]})) || return 0

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n apt-get update\n'
  else
    sudo -n apt-get update
  fi

  local resolved=()
  for pkg in "${packages[@]}"; do
    if ! apt-cache show "$pkg" >/dev/null 2>&1; then
      die "debian-base package does not resolve: $pkg"
    fi
    resolved+=("$pkg")
  done

  if [[ "${DRY_RUN:-0}" == 1 ]]; then
    printf '[dry-run] sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y'
    printf ' %q' "${resolved[@]}"
    printf '\n'
    return 0
  fi

  sudo -n env DEBIAN_FRONTEND=noninteractive apt-get install -y "${resolved[@]}"
}

HOST_CLASS="${HOST_CLASS:-}"
if [[ -z "$HOST_CLASS" ]]; then
  HOST_CLASS="$(detect_host_class)" || die 'host detection failed'
fi

case "$HOST_CLASS" in
  arch-base|debian-base) ;;
  *) die "unsupported host class: $HOST_CLASS" ;;
esac

export HOST_CLASS
info "host_class=$HOST_CLASS"

case "$HOST_CLASS" in
  arch-base)
    install_arch_packages
    ;;
  debian-base)
    install_debian_packages
    ;;
  *)
    die "unsupported host class for package install: $HOST_CLASS"
    ;;
esac
