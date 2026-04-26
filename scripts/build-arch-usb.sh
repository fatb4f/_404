#!/usr/bin/env bash
set -euo pipefail

RAW=${ARCH_USB_RAW:-/tmp/arch-usb.raw}
QCOW2=${ARCH_USB_QCOW2:-/tmp/Arch-Linux-x86_64-basic.qcow2}
SHA256_FILE=${ARCH_USB_SHA256_FILE:-/tmp/Arch-Linux-x86_64-basic.qcow2.SHA256}
TARGET=${ARCH_USB_FLASH_TARGET:-}
IMAGE_URL=${ARCH_USB_IMAGE_URL:-https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-basic.qcow2}
SHA256_URL=${ARCH_USB_SHA256_URL:-https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-basic.qcow2.SHA256}

cleanup() {
  set +e
  rm -f "$QCOW2" "$SHA256_FILE"
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

mkdir -p "$(dirname "$RAW")"
rm -f "$RAW" "$QCOW2" "$SHA256_FILE"

curl -fsSL "$IMAGE_URL" -o "$QCOW2"
curl -fsSL "$SHA256_URL" -o "$SHA256_FILE"

(
  cd "$(dirname "$QCOW2")"
  sha256sum -c "$(basename "$SHA256_FILE")"
)

qemu-img info "$QCOW2"
qemu-img check "$QCOW2"

qemu-img convert -p -f qcow2 -O raw "$QCOW2" "$RAW"

if [[ -n "$TARGET" ]]; then
  dd if="$RAW" of="$TARGET" bs=16M conv=fsync status=progress
  sync
  echo "flashed $RAW to $TARGET"
else
  echo "built $RAW"
fi
