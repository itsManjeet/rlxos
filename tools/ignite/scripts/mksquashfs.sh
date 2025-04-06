#!/bin/sh

set -e

ROOTFS="$OUTPUT_DIR/rootfs"

trap cleanup EXIT

cleanup() {
  rm -fr "$ROOTFS"
}

rsync -auH \
  --exclude="/THIS_IS_NOT_YOUR_ROOT_FILESYSTEM" \
  "$TARGET_DIR/" "$ROOTFS/"

for dir in config data ; do
  rsync -au --delete $PROJECT_DIR/$dir/ $ROOTFS/$dir/
done

export BR2_CONFIG="$DEVICE_CACHE_DIR"/.config
install -d -m 1777 "$ROOTFS"/tmp
install -d -m 0750 "$ROOTFS"/root
install -d -m 0755 "$ROOTFS"/dev
install -d -m 0755 "$ROOTFS"/proc
install -d -m 0755 "$ROOTFS"/sys
install -d -m 0755 "$ROOTFS"/run
find "$ROOTFS"/run/ -mindepth 1 -prune -print0 | xargs -0r rm -rf --
find "$ROOTFS"/tmp/ -mindepth 1 -prune -print0 | xargs -0r rm -rf --

mksquashfs "$ROOTFS" "$OUTPUT_DIR"/rootfs.squashfs -noappend -all-root

