#!/bin/sh

set -e

INITRAMFS="${OUTPUT_DIR}/initramfs"
LIBRARIES="${OUTPUT_DIR}/libraries"

trap cleanup EXIT

cleanup() {
  rm -rf "$INITRAMFS"
  rm -f "$LIBRARIES"
}

# Setting up hierarchy
mkdir -p "$INITRAMFS/usr/bin"
mkdir -p "$INITRAMFS/usr/lib"
mkdir -p "$INITRAMFS/usr/share"
mkdir -p "$INITRAMFS/dev" "$INITRAMFS/sys" "$INITRAMFS/proc"
mkdir -p "$INITRAMFS/boot" "$INITRAMFS/boot" "$INITRAMFS/run"

ln -s bin "$INITRAMFS/usr/sbin"
ln -s usr/bin "$INITRAMFS/sbin"
ln -s usr/bin "$INITRAMFS/bin"

ln -s lib64 "$INITRAMFS/usr/lib64"
ln -s usr/lib "$INITRAMFS/lib"
ln -s usr/lib64 "$INITRAMFS/lib64"

ln -s busybox "$INITRAMFS/usr/bin/sh"
ln -s busybox "$INITRAMFS/usr/bin/modprobe"

ln -s libc.so "$INITRAMFS/usr/lib/ld-musl-x86_64.so.1"

for file in etc/passwd etc/group ; do
  install -D "$TARGET_DIR/$file" "$INITRAMFS/$file"
done

rm -f "$LIBRARIES"

for bin in bin/busybox cmd/shell ; do
  install -D -m 0755 "$TARGET_DIR/$bin" "$INITRAMFS/$bin"
  objdump -p "$TARGET_DIR/$bin" | grep "NEEDED" | awk '{print $2}' >> "$LIBRARIES"
done

libraries=$(sort "$LIBRARIES" | uniq)
for lib in ${libraries} ; do
  objdump -p "$TARGET_DIR/lib/$lib" | grep "NEEDED" | awk '{print $2}' >> "$LIBRARIES"
done
# install runtime libraries
for lib in $(sort "$LIBRARIES" | uniq) ; do
  cp "$TARGET_DIR/lib/$lib" "$INITRAMFS/lib/$lib"
done

install -D -m 0755 "$TARGET_DIR/cmd/init" "$INITRAMFS/init"

KERNEL_VERSION=$(ls -1 "$TARGET_DIR/lib/modules/")

KERNEL_SUBSYSTEM="crypto fs lib"
KERNEL_DRIVERS="block md firewire nvme parport input scsi message virtio hid usb/host usb/storage"

KERNEL_MODULES=""
for s in $KERNEL_SUBSYSTEM ; do
  KERNEL_MODULES="$KERNEL_MODULES lib/modules/$KERNEL_VERSION/kernel/$s"
done

for s in $KERNEL_DRIVERS ; do
  KERNEL_MODULES="$KERNEL_MODULES lib/modules/$KERNEL_VERSION/kernel/drivers/$s"
done

for mods in $KERNEL_MODULES ; do
  for mod in $(find "$TARGET_DIR/$mods/" -type f -name "*.ko*") ; do
    mod=$(echo "$mod" | sed "s#$TARGET_DIR##g")
    install -D -m 0644 "$TARGET_DIR/$mod" "$INITRAMFS/$mod"
  done
done

cp -a "$TARGET_DIR"/lib/modules/"$KERNEL_VERSION"/modules.* "$INITRAMFS/lib/modules/$KERNEL_VERSION/"

depmod -a -b "$INITRAMFS" "$KERNEL_VERSION"

(cd "$INITRAMFS/" ; find . -print0 | cpio --null -ov --format=newc --quiet 2>/dev/null) > "${INITRAMFS}.img"

