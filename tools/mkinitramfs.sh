#!/bin/sh

set -e

INITRAMFS="${IMAGES_PATH}/initramfs"
LIBRARIES="${IMAGES_PATH}/libraries"

trap cleanup EXIT

cleanup() {
  rm -rf "$INITRAMFS"
  rm -f "$LIBRARIES"
}

# Setting up hierarchy
mkdir -p "$INITRAMFS/cmd"
mkdir -p "$INITRAMFS/lib"
mkdir -p "$INITRAMFS/dev" "$INITRAMFS/sys" "$INITRAMFS/proc"
mkdir -p "$INITRAMFS/boot" "$INITRAMFS/boot" "$INITRAMFS/run"

ln -s busybox "$INITRAMFS/cmd/sh"
ln -s busybox "$INITRAMFS/cmd/modprobe"

ln -s libc.so "$INITRAMFS/lib/ld-musl-x86_64.so.1"

for file in etc/passwd etc/group ; do
  install -D "$SYSTEM_PATH/$file" "$INITRAMFS/$file"
done

rm -f "$LIBRARIES"

for bin in cmd/busybox cmd/shell ; do
  install -D -m 0755 "$SYSTEM_PATH/$bin" "$INITRAMFS/$bin"
  objdump -p "$SYSTEM_PATH/$bin" | grep "NEEDED" | awk '{print $2}' >> "$LIBRARIES"
done

libraries=$(sort "$LIBRARIES" | uniq)
for lib in ${libraries} ; do
  objdump -p "$SYSTEM_PATH/lib/$lib" | grep "NEEDED" | awk '{print $2}' >> "$LIBRARIES"
done
# install runtime libraries
for lib in $(sort "$LIBRARIES" | uniq) ; do
  cp "$SYSTEM_PATH/lib/$lib" "$INITRAMFS/lib/$lib"
done

install -D -m 0755 "$SYSTEM_PATH/cmd/init" "$INITRAMFS/init"

KERNEL_VERSION=$(ls -1 "$SYSTEM_PATH/lib/modules/")

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
  for mod in $(find "$SYSTEM_PATH/$mods/" -type f -name "*.ko*") ; do
    mod=$(echo "$mod" | sed "s#$SYSTEM_PATH##g")
    install -D -m 0644 "$SYSTEM_PATH/$mod" "$INITRAMFS/$mod"
  done
done

cp -a "$SYSTEM_PATH"/lib/modules/"$KERNEL_VERSION"/modules.* "$INITRAMFS/lib/modules/$KERNEL_VERSION/"

depmod -a -b "$INITRAMFS" "$KERNEL_VERSION"

(cd "$INITRAMFS/" ; find . -print0 | cpio --null -ov --format=newc --quiet 2>/dev/null) > "$1"