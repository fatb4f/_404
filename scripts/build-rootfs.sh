#!/usr/bin/env bash
set -euo pipefail

ROOT="${GITHUB_WORKSPACE:-$(pwd)}"
WORKDIR="$ROOT/work"
OUTDIR="$ROOT/out"
ROOTFS_DIR="$WORKDIR/rootfs"
ROOTFS_IMG=${ARCH_ROOTFS_IMG:-"$OUTDIR/arch-rootfs.ext4"}
ROOTFS_IMG_ZST=${ARCH_ROOTFS_IMG_ZST:-"$OUTDIR/arch-rootfs.ext4.zst"}
ROOTFS_SIZE=${ARCH_ROOTFS_SIZE:-6G}

mkdir -p "$WORKDIR" "$OUTDIR"
rm -rf "$ROOTFS_DIR"
mkdir -p "$ROOTFS_DIR"

cat > "$WORKDIR/build-rootfs-in-docker.sh" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

pacman-key --init
pacman-key --populate archlinux
pacman -Sy --noconfirm archlinux-keyring
pacman -S --noconfirm --needed arch-install-scripts

mkdir -p /work/rootfs
pacstrap -c -G -M /work/rootfs \
  base \
  bash \
  coreutils \
  filesystem \
  findutils \
  gawk \
  grep \
  iproute2 \
  less \
  nano \
  procps-ng \
  sed \
  shadow \
  sudo \
  systemd \
  tar \
  util-linux
EOF
chmod +x "$WORKDIR/build-rootfs-in-docker.sh"

sudo docker pull archlinux:latest

sudo docker run --rm \
  --privileged \
  -v "$WORKDIR:/work" \
  archlinux:latest \
  /work/build-rootfs-in-docker.sh

rm -f "$ROOTFS_IMG" "$ROOTFS_IMG_ZST"
truncate -s "$ROOTFS_SIZE" "$ROOTFS_IMG"
sudo mkfs.ext4 -F -L ARCHROOT -d "$ROOTFS_DIR" "$ROOTFS_IMG"
sudo zstd -19 -T0 -f "$ROOTFS_IMG" -o "$ROOTFS_IMG_ZST"

echo "Rootfs artifacts written to $OUTDIR"
