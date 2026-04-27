#!/usr/bin/env bash
set -euo pipefail

RAW=${ARCH_USB_RAW:-/tmp/arch-usb.raw}
TARGET=${ARCH_USB_FLASH_TARGET:-}
FINAL_SIZE=${ARCH_USB_FINAL_SIZE:-13G}
ROOTFS_REPO=${ARCH_USB_ROOTFS_REPO:-fatb4f/baguette}
ROOTFS_WORKFLOW=${ARCH_USB_ROOTFS_WORKFLOW:-build-arch-baguette.yml}
ROOTFS_ARTIFACT=${ARCH_USB_ROOTFS_ARTIFACT:-arch-rootfs-intermediate}
ROOTFS_RUN_ID=${ARCH_USB_ROOTFS_RUN_ID:-}
ROOTFS_TAR=${ARCH_USB_ROOTFS_TAR:-}
ROOTFS_TAR_ZST=${ARCH_USB_ROOTFS_TAR_ZST:-}
SUBMARINE_URL=${ARCH_USB_SUBMARINE_URL:-https://nightly.link/FyraLabs/submarine/workflows/build/main/submarine-x86_64.zip}
SUBMARINE_ZIP=${ARCH_USB_SUBMARINE_ZIP:-/tmp/submarine-x86_64.zip}
SUBMARINE_KPART=${ARCH_USB_SUBMARINE_KPART:-}
MNT=""
LOOP_DEV=""

cleanup() {
  set +e
  for path in \
    "${MNT:-}/dev/pts" \
    "${MNT:-}/dev" \
    "${MNT:-}/proc" \
    "${MNT:-}/sys" \
    "${MNT:-}/run" \
    "${MNT:-}/etc/resolv.conf"
  do
    if [[ -n "${MNT:-}" && -e "$path" ]]; then
      umount -R "$path" 2>/dev/null || umount "$path" 2>/dev/null || true
    fi
  done
  if [[ -n "${MNT:-}" ]]; then
    umount "$MNT" 2>/dev/null || true
    rmdir "$MNT" 2>/dev/null || true
  fi
  if [[ -n "${LOOP_DEV:-}" ]]; then
    losetup -d "$LOOP_DEV" 2>/dev/null || true
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

for cmd in bash dd losetup mkfs.ext4 mount qemu-img sgdisk tar udevadm zstd cgpt blkid; do
  need_cmd "$cmd"
done

if [[ -z "$ROOTFS_TAR" && -z "$ROOTFS_TAR_ZST" ]]; then
  need_cmd gh
fi

if [[ -z "$SUBMARINE_KPART" ]]; then
  need_cmd curl
  need_cmd unzip
fi

download_rootfs() {
  local tmpdir run_id

  if [[ -n "$ROOTFS_TAR" && -f "$ROOTFS_TAR" ]]; then
    return
  fi

  if [[ -n "$ROOTFS_TAR_ZST" && -f "$ROOTFS_TAR_ZST" ]]; then
    ROOTFS_TAR="$ROOTFS_TAR_ZST"
    return
  fi

  tmpdir="$(mktemp -d /tmp/arch-rootfs.XXXXXX)"
  if [[ -n "$ROOTFS_RUN_ID" ]]; then
    run_id="$ROOTFS_RUN_ID"
  else
    run_id="$(
      gh api "repos/$ROOTFS_REPO/actions/workflows/$ROOTFS_WORKFLOW/runs?status=success&branch=main&per_page=1" \
        --jq '.workflow_runs[0].id'
    )"
  fi
  if [[ -z "$run_id" || "$run_id" == "null" ]]; then
    echo "could not determine a successful rootfs run id" >&2
    exit 1
  fi

  gh run download "$run_id" -R "$ROOTFS_REPO" -n "$ROOTFS_ARTIFACT" -D "$tmpdir"

  if [[ -f "$tmpdir/arch-rootfs.tar" ]]; then
    ROOTFS_TAR="$tmpdir/arch-rootfs.tar"
  elif [[ -f "$tmpdir/arch-rootfs.tar.zst" ]]; then
    ROOTFS_TAR_ZST="$tmpdir/arch-rootfs.tar.zst"
    ROOTFS_TAR="$ROOTFS_TAR_ZST"
  else
    echo "rootfs artifact did not contain arch-rootfs.tar or arch-rootfs.tar.zst" >&2
    exit 1
  fi
}

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

extract_rootfs() {
  local root_uuid

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
  root_uuid="$(blkid -s UUID -o value "${LOOP_DEV}p2")"
  if [[ -z "$root_uuid" ]]; then
    echo "could not determine root filesystem UUID" >&2
    exit 1
  fi

  MNT="$(mktemp -d /tmp/arch-usb.XXXXXX)"
  mount "${LOOP_DEV}p2" "$MNT"

  if [[ "$ROOTFS_TAR" == *.zst ]]; then
    zstd -dc "$ROOTFS_TAR" | tar --numeric-owner --xattrs --acls -C "$MNT" -xpf -
  else
    tar --numeric-owner --xattrs --acls -C "$MNT" -xpf "$ROOTFS_TAR"
  fi

  mkdir -p "$MNT/boot/grub"
  mkdir -p "$MNT/etc/pacman.d"
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
    pacman -S --noconfirm --needed linux linux-firmware grub
    mkdir -p /boot/grub
    grub-mkconfig -o /boot/grub/grub.cfg
  '

  sync
  umount "$MNT/etc/resolv.conf" 2>/dev/null || true
  umount "$MNT/run" 2>/dev/null || true
  umount "$MNT/sys" 2>/dev/null || true
  umount "$MNT/proc" 2>/dev/null || true
  umount "$MNT/dev/pts" 2>/dev/null || true
  umount "$MNT/dev" 2>/dev/null || true
  umount "$MNT"

  dd if="$SUBMARINE_KPART" of="${LOOP_DEV}p1" bs=4M conv=fsync status=progress
  sync

  losetup -d "$LOOP_DEV"
  LOOP_DEV=""
  rmdir "$MNT" 2>/dev/null || true
  MNT=""
}

download_rootfs
download_submarine
extract_rootfs

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
