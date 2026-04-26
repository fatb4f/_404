#!/usr/bin/env bash
set -euo pipefail

ISO=${ARCH_USB_ISO:-/tmp/archlinux-2026.04.01-x86_64.iso}
SHA256_FILE=${ARCH_USB_SHA256_FILE:-/tmp/archlinux-2026.04.01-x86_64.iso.sha256}
TARGET=${ARCH_USB_FLASH_TARGET:-}
IMAGE_URL=${ARCH_USB_IMAGE_URL:-https://geo.mirror.pkgbuild.com/iso/2026.04.01/archlinux-2026.04.01-x86_64.iso}
SHA256_URL=${ARCH_USB_SHA256_URL:-https://geo.mirror.pkgbuild.com/iso/2026.04.01/sha256sums.txt}

cleanup() {
  set +e
  rm -f "$SHA256_FILE"
}
trap cleanup EXIT

if [[ -n "$TARGET" && ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo -E -- bash "$0" "$@"
fi

if [[ -n "$TARGET" ]]; then
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    echo "refusing to flash $TARGET without root" >&2
    exit 1
  fi

  if [[ ! -b "$TARGET" ]]; then
    echo "target $TARGET is not a block device" >&2
    exit 1
  fi

  if [[ "$(lsblk -dn -o RM "$TARGET" 2>/dev/null | tr -d '[:space:]')" != "1" ]]; then
    echo "target $TARGET is not marked removable" >&2
    exit 1
  fi
fi

mkdir -p "$(dirname "$ISO")"
rm -f "$ISO" "$SHA256_FILE"

curl -fsSL "$IMAGE_URL" -o "$ISO"
curl -fsSL "$SHA256_URL" -o "$SHA256_FILE"

expected_sum="$(
  awk '
    $2 == "archlinux-2026.04.01-x86_64.iso" { print $1; exit }
  ' "$SHA256_FILE"
)"

if [[ -z "$expected_sum" ]]; then
  echo "could not locate ISO checksum in sha256sums.txt" >&2
  exit 1
fi

actual_sum="$(sha256sum "$ISO" | awk '{print $1}')"
if [[ "$actual_sum" != "$expected_sum" ]]; then
  echo "checksum mismatch for $ISO" >&2
  exit 1
fi

if [[ -n "$TARGET" ]]; then
  dd if="$ISO" of="$TARGET" bs=4M conv=fsync status=progress
  sync
  echo "flashed $ISO to $TARGET"
else
  echo "built $ISO"
fi
