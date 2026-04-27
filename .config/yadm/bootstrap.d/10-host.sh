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
