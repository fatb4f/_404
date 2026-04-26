#!/usr/bin/env bash
set -euo pipefail

RAW=${ARCH_USB_RAW:-/tmp/arch-usb.raw}
MNT=${ARCH_USB_MNT:-/mnt/arch-usb}
QEMU_LOG=${ARCH_USB_QEMU_LOG:-/tmp/arch-usb-qemu.log}
BOOTSTRAP_TARBALL=${ARCH_USB_BOOTSTRAP_TARBALL:-/tmp/archlinux-bootstrap-x86_64.tar.zst}
TARGET=${ARCH_USB_FLASH_TARGET:-}
IMAGE_SIZE=${ARCH_USB_IMAGE_SIZE:-13G}
HOSTNAME=${ARCH_USB_HOSTNAME:-arch-usb}
TIMEZONE=${ARCH_USB_TIMEZONE:-America/Toronto}
USER_NAME=${ARCH_USB_USER:-_404}
USER_PASS=${ARCH_USB_USER_PASS:-me0w}
ROOT_PASS=${ARCH_USB_ROOT_PASS:-me0w}
BOOT_TIMEOUT=${ARCH_USB_BOOT_TIMEOUT:-120}
MIRROR_URL=${ARCH_USB_MIRROR_URL:-https://geo.mirror.pkgbuild.com}

cleanup() {
  set +e
  umount -R "$MNT" 2>/dev/null || true
  if [[ -n "${LOOP_DEV:-}" ]]; then
    losetup -d "$LOOP_DEV" 2>/dev/null || true
  fi
}
trap cleanup EXIT

require_root() {
  if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
    exec sudo -E -- bash "$0" "$@"
  fi
}

require_root "$@"

if [[ -n "$TARGET" ]]; then
  if [[ ! -b "$TARGET" ]]; then
    echo "target $TARGET is not a block device" >&2
    exit 1
  fi

  if [[ "$(lsblk -dn -o RM "$TARGET" 2>/dev/null | tr -d '[:space:]')" != "1" ]]; then
    echo "target $TARGET is not marked removable" >&2
    exit 1
  fi
fi

mkdir -p "$MNT"
rm -f "$RAW" "$QEMU_LOG" "$BOOTSTRAP_TARBALL"

truncate -s "$IMAGE_SIZE" "$RAW"
LOOP_DEV="$(losetup --find --show --partscan "$RAW")"

sgdisk -Z "$LOOP_DEV"
sgdisk -n1:0:+512M -t1:ef00 -c1:ARCH_EFI "$LOOP_DEV"
sgdisk -n2:0:0 -t2:8300 -c2:ARCH_ROOT "$LOOP_DEV"
udevadm settle

mkfs.vfat -F32 -n ARCH_EFI "${LOOP_DEV}p1"
mkfs.ext4 -F -L ARCH_ROOT "${LOOP_DEV}p2"

mount "${LOOP_DEV}p2" "$MNT"
mkdir -p "$MNT/boot"
mount "${LOOP_DEV}p1" "$MNT/boot"

curl -fsSL \
  "${MIRROR_URL}/iso/latest/archlinux-bootstrap-x86_64.tar.zst" \
  -o "$BOOTSTRAP_TARBALL"
tar --zstd -xpf "$BOOTSTRAP_TARBALL" -C "$MNT" --strip-components=1

cat >"$MNT/etc/pacman.d/mirrorlist" <<EOF
Server = ${MIRROR_URL}/\$repo/os/\$arch
EOF

genfstab -U "$MNT" > "$MNT/etc/fstab"

ROOT_UUID="$(blkid -s UUID -o value "${LOOP_DEV}p2")"

arch-chroot "$MNT" /bin/bash <<EOF
set -euo pipefail

pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm mkinitcpio
pacman -Syu --noconfirm \
  base linux linux-firmware sudo git vim networkmanager openssh

ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
hwclock --systohc

sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
printf 'LANG=en_US.UTF-8\n' > /etc/locale.conf

printf '%s\n' "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<HOSTS
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.localdomain $HOSTNAME
HOSTS

echo "root:$ROOT_PASS" | chpasswd
useradd -m -G wheel -s /bin/bash "$USER_NAME"
echo "$USER_NAME:$USER_PASS" | chpasswd

sed -i 's/^# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

systemctl enable NetworkManager
systemctl enable serial-getty@ttyS0.service

bootctl install --esp-path=/boot

mkdir -p /boot/loader/entries
cat > /boot/loader/loader.conf <<LOADER
default arch.conf
timeout 3
console-mode max
editor no
LOADER

cat > /boot/loader/entries/arch.conf <<ENTRY
title Arch USB
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=$ROOT_UUID rw console=tty0 console=ttyS0,115200n8 loglevel=4
ENTRY
EOF

sync
umount -R "$MNT"
losetup -d "$LOOP_DEV"
unset LOOP_DEV

if [[ -e /dev/kvm ]]; then
  QEMU_ACCEL=( -enable-kvm -machine q35,accel=kvm -cpu host )
else
  QEMU_ACCEL=( -machine q35,accel=tcg -cpu max )
fi

OVMF_CODE=""
OVMF_VARS_TEMPLATE=""
for candidate in \
  /usr/share/OVMF/OVMF_CODE_4M.fd \
  /usr/share/OVMF/OVMF_CODE.fd \
  /usr/share/OVMF/x64/OVMF_CODE.fd; do
  [[ -r "$candidate" ]] && OVMF_CODE="$candidate" && break
done
for candidate in \
  /usr/share/OVMF/OVMF_VARS_4M.fd \
  /usr/share/OVMF/OVMF_VARS.fd \
  /usr/share/OVMF/x64/OVMF_VARS.fd; do
  [[ -r "$candidate" ]] && OVMF_VARS_TEMPLATE="$candidate" && break
done

if [[ -z "$OVMF_CODE" || -z "$OVMF_VARS_TEMPLATE" ]]; then
  echo "could not locate OVMF firmware" >&2
  exit 1
fi

OVMF_VARS=${ARCH_USB_OVMF_VARS:-/tmp/OVMF_VARS.arch-usb.fd}
cp "$OVMF_VARS_TEMPLATE" "$OVMF_VARS"

timeout "${BOOT_TIMEOUT}s" qemu-system-x86_64 \
  "${QEMU_ACCEL[@]}" \
  -m 2048 \
  -smp 2 \
  -display none \
  -serial mon:stdio \
  -monitor none \
  -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
  -drive if=pflash,format=raw,file="$OVMF_VARS" \
  -drive file="$RAW",format=raw,if=virtio \
  >"$QEMU_LOG" 2>&1 || true

if ! rg -q 'login:' "$QEMU_LOG"; then
  echo "qemu boot did not reach a login prompt" >&2
  tail -n 80 "$QEMU_LOG" >&2 || true
  exit 1
fi

if [[ -n "$TARGET" ]]; then
  dd if="$RAW" of="$TARGET" bs=16M conv=fsync status=progress
  sync
  echo "flashed $RAW to $TARGET"
else
  echo "built $RAW"
fi
