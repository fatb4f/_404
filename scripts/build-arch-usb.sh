#!/usr/bin/env bash
set -euo pipefail

RAW=${ARCH_USB_RAW:-/tmp/arch-usb.raw}
TARGET=${ARCH_USB_FLASH_TARGET:-}
FINAL_SIZE=${ARCH_USB_FINAL_SIZE:-13G}
ROOTFS_SRC=${ARCH_USB_ROOTFS_IMG_ZST:-${ARCH_USB_ROOTFS_IMG:-}}
SUBMARINE_URL=${ARCH_USB_SUBMARINE_URL:-https://nightly.link/FyraLabs/submarine/workflows/build/main/submarine-x86_64.zip}
SUBMARINE_ZIP=${ARCH_USB_SUBMARINE_ZIP:-/tmp/submarine-x86_64.zip}
SUBMARINE_KPART=${ARCH_USB_SUBMARINE_KPART:-}
MNT=""
SRC_MNT=""
LOOP_DEV=""
SRC_IMG=""

cleanup() {
  set +e
  for path in \
    "${SRC_MNT:-}/dev/pts" \
    "${SRC_MNT:-}/dev" \
    "${SRC_MNT:-}/proc" \
    "${SRC_MNT:-}/sys" \
    "${SRC_MNT:-}/run" \
    "${MNT:-}/dev/pts" \
    "${MNT:-}/dev" \
    "${MNT:-}/proc" \
    "${MNT:-}/sys" \
    "${MNT:-}/run" \
    "${SRC_MNT:-}" \
    "${MNT:-}" \
    "${SRC_IMG:-}"
  do
    if [[ -n "${SRC_MNT:-}" && -e "$path" ]]; then
      umount -R "$path" 2>/dev/null || umount "$path" 2>/dev/null || true
    fi
    if [[ -n "${MNT:-}" && -e "$path" ]]; then
      umount -R "$path" 2>/dev/null || umount "$path" 2>/dev/null || true
    fi
  done
  if [[ -n "${SRC_MNT:-}" ]]; then
    rmdir "$SRC_MNT" 2>/dev/null || true
  fi
  if [[ -n "${MNT:-}" ]]; then
    rmdir "$MNT" 2>/dev/null || true
  fi
  if [[ -n "${LOOP_DEV:-}" ]]; then
    losetup -d "$LOOP_DEV" 2>/dev/null || true
  fi
  if [[ -n "${SRC_IMG:-}" ]]; then
    rm -f "$SRC_IMG"
  fi
}
trap cleanup EXIT

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  exec sudo -E -- bash "$0" "$@"
fi

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "missing required command: $1" >&2
    exit 1
  }
}

for cmd in bash dd losetup mkfs.ext4 mount qemu-img sgdisk rsync udevadm zstd cgpt blkid; do
  need_cmd "$cmd"
done

if [[ -z "$ROOTFS_SRC" ]]; then
  echo "missing rootfs artifact path; set ARCH_USB_ROOTFS_IMG or ARCH_USB_ROOTFS_IMG_ZST" >&2
  exit 1
fi

if [[ -z "$SUBMARINE_KPART" ]]; then
  need_cmd curl
  need_cmd unzip
fi

download_submarine() {
  local tmpdir

  if [[ -n "$SUBMARINE_KPART" && -f "$SUBMARINE_KPART" ]]; then
    return
  fi

  tmpdir="$(mktemp -d /tmp/submarine.XXXXXX)"
  curl -fsSL "$SUBMARINE_URL" -o "$SUBMARINE_ZIP"
  unzip -o -q "$SUBMARINE_ZIP" -d "$tmpdir"

  if [[ -f "$tmpdir/submarine-x86.kpart" ]]; then
    SUBMARINE_KPART="$tmpdir/submarine-x86.kpart"
  elif [[ -f "$tmpdir/submarine-x86_64.kpart" ]]; then
    SUBMARINE_KPART="$tmpdir/submarine-x86_64.kpart"
  else
    echo "submarine artifact did not contain a kpart payload" >&2
    exit 1
  fi
}

prepare_rootfs_source() {
  if [[ "$ROOTFS_SRC" == *.zst ]]; then
    SRC_IMG="$(mktemp /tmp/arch-rootfs-src.XXXXXX.img)"
    zstd -dc "$ROOTFS_SRC" > "$SRC_IMG"
  else
    SRC_IMG="$ROOTFS_SRC"
  fi
}

download_submarine
prepare_rootfs_source

mkdir -p "$(dirname "$RAW")"
rm -f "$RAW"

qemu-img create -f raw "$RAW" "$FINAL_SIZE"
sgdisk -o "$RAW"
sgdisk -n1:2048:+16M -t1:7F00 -c1:Submarine "$RAW"
sgdisk -n2:0:0 -t2:8300 -c2:Arch\ Linux\ root "$RAW"

LOOP_DEV="$(losetup --find --show --partscan "$RAW")"
udevadm settle

cgpt add -i 1 -t kernel -P 15 -T 1 -S 1 "$LOOP_DEV"

mkfs.ext4 -F -L ARCHROOT "${LOOP_DEV}p2"
root_fstype="$(lsblk -no FSTYPE "${LOOP_DEV}p2" | tr -d '[:space:]')"
if [[ "$root_fstype" != ext4 ]]; then
  echo "root partition is not ext4: $root_fstype" >&2
  exit 1
fi
root_uuid="$(blkid -s UUID -o value "${LOOP_DEV}p2")"
if [[ -z "$root_uuid" ]]; then
  echo "could not determine root filesystem UUID" >&2
  exit 1
fi

SRC_MNT="$(mktemp -d /tmp/arch-rootfs-src.XXXXXX)"
MNT="$(mktemp -d /tmp/arch-usb.XXXXXX)"
mount -o ro,loop "$SRC_IMG" "$SRC_MNT"
mount "${LOOP_DEV}p2" "$MNT"

rsync -aHAX --numeric-ids "$SRC_MNT"/ "$MNT"/

mkdir -p "$MNT/boot/grub"
mkdir -p "$MNT/etc/pacman.d"
cat >"$MNT/etc/vconsole.conf" <<'EOF'
KEYMAP=us
EOF
cat >"$MNT/etc/pacman.conf" <<'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch

[extra]
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch

[multilib]
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
EOF
cat >"$MNT/etc/fstab" <<EOF
UUID=$root_uuid / ext4 defaults 0 1
EOF

for dir in dev dev/pts proc sys run; do
  mkdir -p "$MNT/$dir"
done
mount --bind /dev "$MNT/dev"
mount --bind /dev/pts "$MNT/dev/pts"
mount --bind /proc "$MNT/proc"
mount --bind /sys "$MNT/sys"
mount --bind /run "$MNT/run"
if [[ -f /etc/resolv.conf ]]; then
  mkdir -p "$MNT/etc"
  : >"$MNT/etc/resolv.conf"
  mount --bind /etc/resolv.conf "$MNT/etc/resolv.conf"
fi

chroot "$MNT" /usr/bin/env bash -lc '
  set -euo pipefail
  pacman-key --init
  pacman-key --populate archlinux
  pacman -Sy --noconfirm archlinux-keyring
  pacman -S --noconfirm --needed mkinitcpio linux linux-firmware grub
  mkdir -p /boot/grub
  grub-mkconfig -o /boot/grub/grub.cfg
'

sync
umount -R "$MNT" 2>/dev/null || true
umount -R "$SRC_MNT" 2>/dev/null || true

dd if="$SUBMARINE_KPART" of="${LOOP_DEV}p1" bs=4M conv=fsync status=progress
sync

losetup -d "$LOOP_DEV"
LOOP_DEV=""
rmdir "$MNT" 2>/dev/null || true
MNT=""
rmdir "$SRC_MNT" 2>/dev/null || true
SRC_MNT=""
rm -f "$SRC_IMG" 2>/dev/null || true
SRC_IMG=""

if [[ -n "$TARGET" ]]; then
  if [[ ! -b "$TARGET" ]]; then
    echo "target $TARGET is not a block device" >&2
    exit 1
  fi

  if [[ "$(lsblk -dn -o RM "$TARGET" 2>/dev/null | tr -d '[:space:]')" != "1" ]]; then
    echo "target $TARGET is not marked removable" >&2
    exit 1
  fi

  dd if="$RAW" of="$TARGET" bs=16M conv=fsync status=progress
  sync
  echo "flashed $RAW to $TARGET"
else
  echo "built $RAW"
fi
