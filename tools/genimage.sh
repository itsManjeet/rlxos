#!/bin/sh

set -e

mkdir -p "$IMAGES_PATH"/iso/boot/grub/x86_64-efi
mkdir -p "$IMAGES_PATH"/iso/boot/grub/fonts
mkdir -p "$IMAGES_PATH"/iso/efi/boot
mkdir -p "$IMAGES_PATH"/iso/isolinux

for file in chain.c32 isolinux.bin isolinux.bin ldlinux.c32 libutil.c32 reboot.c32 vesamenu.c32 libcom32.c32 poweroff.c32 ; do
    cp "$HOST_PATH/share/syslinux/$file" "$IMAGES_PATH"/iso/isolinux
done

[ -f "$HOST_PATH/share/grub/unicode.pf2" ] && cp "$HOST_PATH/share/grub/unicode.pf2" "$IMAGES_PATH"/iso/boot/grub/fonts/

echo "set prefix=/boot/grub" > "$IMAGES_PATH"/iso/boot/grub-early.cfg
cp -a "$TARGET_PATH"/lib/grub/x86_64-efi/*.mod \
    "$TARGET_PATH"/lib/grub/x86_64-efi/*.lst \
    "$IMAGES_PATH"/iso/boot/grub/x86_64-efi/

echo "set prefix=/boot/grub" > "$IMAGES_PATH"/iso/boot/grub-early.cfg

grub-mkimage \
    -d "$TARGET_PATH/lib/grub/x86_64-efi/" \
    -c "$IMAGES_PATH"/iso/boot/grub-early.cfg \
    -o "$IMAGES_PATH"/iso/efi/boot/bootx64.efi \
    -O x86_64-efi \
    -p "" iso9660 normal search search_fs_file
dd if=/dev/zero of="$IMAGES_PATH"/iso/boot/efiboot.img count=4096
mkdosfs -n RLXOS-UEFI "$IMAGES_PATH"/iso/boot/efiboot.img
mmd -i "$IMAGES_PATH"/iso/boot/efiboot.img ::/EFI
mmd -i "$IMAGES_PATH"/iso/boot/efiboot.img ::/EFI/BOOT
mcopy -i "$IMAGES_PATH"/iso/boot/efiboot.img "$IMAGES_PATH"/iso/efi/boot/bootx64.efi ::/EFI/BOOT

install -vDm0644 /dev/stdin "$IMAGES_PATH"/iso/boot/grub/grub.cfg << EOF
set default="RLXOS GNU/Linux"
set timeout=10

menuentry "RLXOS GNU/Linux" {
	insmod all_video

	linux /boot/kernel.img root=/dev/sr0 rootfs-type=iso9660 live console=ttyS0
	initrd /boot/initramfs.img
}
EOF

install -vDm0644 /dev/stdin "$IMAGES_PATH"/iso/isolinux/isolinux.cfg << EOF
DEFAULT RLXOS
    LABEL RLXOS
    KERNEL /boot/kernel.img
    APPEND initrd=/boot/initramfs.img root=/dev/sr0 rootfs-type=iso9660 live console=ttyS0
EOF

cp "$IMAGES_PATH"/kernel.img \
   "$IMAGES_PATH"/initramfs.img \
   "$IMAGES_PATH"/iso/boot/

cp "$IMAGES_PATH/system.img" \
  "$IMAGES_PATH/iso/system.img"

xorriso -as mkisofs \
    -isohybrid-mbr "$HOST_PATH/share/syslinux/isohdpfx.bin" \
    -c isolinux/boot.cat \
    -b isolinux/isolinux.bin \
      -no-emul-boot \
      -boot-load-size 4 \
      -boot-info-table \
    -eltorito-alt-boot \
    -e boot/efiboot.img \
      -no-emul-boot \
      -isohybrid-gpt-basdat \
      -volid RLXOS \
    -o "$IMAGES_PATH"/installer.iso "$IMAGES_PATH"/iso/

rm -rf "$IMAGES_PATH"/iso