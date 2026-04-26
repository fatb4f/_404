#!/usr/bin/env bash
set -euo pipefail

RAW=${ARCH_USB_RAW:-/tmp/arch-usb.raw}
QCOW2=${ARCH_USB_QCOW2:-/tmp/Arch-Linux-x86_64-basic.qcow2}
SHA256_FILE=${ARCH_USB_SHA256_FILE:-/tmp/Arch-Linux-x86_64-basic.qcow2.SHA256}
TARGET=${ARCH_USB_FLASH_TARGET:-}
IMAGE_URL=${ARCH_USB_IMAGE_URL:-https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-basic.qcow2}
SHA256_URL=${ARCH_USB_SHA256_URL:-https://geo.mirror.pkgbuild.com/images/latest/Arch-Linux-x86_64-basic.qcow2.SHA256}
FINAL_SIZE=${ARCH_USB_FINAL_SIZE:-13G}
ROOT_SHRINK_SIZE=${ARCH_USB_ROOT_SHRINK_SIZE:-12G}
ROOT_PART_NUM=${ARCH_USB_ROOT_PART_NUM:-3}
ROOT_PART_NAME=${ARCH_USB_ROOT_PART_NAME:-Arch Linux root}
MNT=""
LOOP_DEV=""

cleanup() {
  set +e
  if [[ -n "${MNT:-}" ]]; then
    umount "$MNT" 2>/dev/null || true
    rmdir "$MNT" 2>/dev/null || true
  fi
  if [[ -n "${LOOP_DEV:-}" ]]; then
    losetup -d "$LOOP_DEV" 2>/dev/null || true
  fi
  rm -f "$QCOW2" "$SHA256_FILE"
}
trap cleanup EXIT

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
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
qemu-img convert -p -f qcow2 -O raw "$QCOW2" "$RAW"

LOOP_DEV="$(losetup --find --show --partscan "$RAW")"
udevadm settle

ROOT_PART="${LOOP_DEV}p${ROOT_PART_NUM}"
MNT="$(mktemp -d /tmp/arch-usb.XXXXXX)"

mount "$ROOT_PART" "$MNT"
btrfs filesystem resize "$ROOT_SHRINK_SIZE" "$MNT"
sync
ROOT_START="$(lsblk -no START "$ROOT_PART" | tr -d '[:space:]')"
if [[ -z "$ROOT_START" ]]; then
  echo "could not determine root partition start" >&2
  exit 1
fi
umount "$MNT"
losetup -d "$LOOP_DEV"
LOOP_DEV=""

truncate -s "$FINAL_SIZE" "$RAW"
sgdisk --move-second-header \
  --delete="$ROOT_PART_NUM" \
  --new="$ROOT_PART_NUM:$ROOT_START:0" \
  --typecode="$ROOT_PART_NUM:8304" \
  --change-name="$ROOT_PART_NUM:$ROOT_PART_NAME" \
  "$RAW"

LOOP_DEV="$(losetup --find --show --partscan "$RAW")"
udevadm settle
ROOT_PART="${LOOP_DEV}p${ROOT_PART_NUM}"
mount "$ROOT_PART" "$MNT"
btrfs filesystem resize max "$MNT"
sync
umount "$MNT"
losetup -d "$LOOP_DEV"
LOOP_DEV=""
rm -rf "$MNT"
MNT=""

if [[ -n "$TARGET" ]]; then
  dd if="$RAW" of="$TARGET" bs=16M conv=fsync status=progress
  sync
  echo "flashed $RAW to $TARGET"
else
  echo "built $RAW"
fi
