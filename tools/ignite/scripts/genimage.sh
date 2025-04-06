#!/bin/sh

set -e

export PATH=/usr/bin:/usr/sbin:/bin:/sbin

mkdir -p "$OUTPUT_DIR"/iso/boot/grub/x86_64-efi
mkdir -p "$OUTPUT_DIR"/iso/boot/grub/fonts
mkdir -p "$OUTPUT_DIR"/iso/efi/boot
mkdir -p "$OUTPUT_DIR"/iso/isolinux

for file in chain.c32 isolinux.bin isolinux.bin ldlinux.c32 libutil.c32 reboot.c32 vesamenu.c32 libcom32.c32 poweroff.c32 ; do
    cp "$HOST_DIR/share/syslinux/$file" "$OUTPUT_DIR"/iso/isolinux
done

[ -f "$HOST_DIR/share/grub/unicode.pf2" ] && cp "$HOST_DIR/share/grub/unicode.pf2" "$OUTPUT_DIR"/iso/boot/grub/fonts/

echo "set prefix=/boot/grub" > "$OUTPUT_DIR"/iso/boot/grub-early.cfg
cp -a "$TARGET_DIR"/lib/grub/x86_64-efi/*.mod \
    "$TARGET_DIR"/lib/grub/x86_64-efi/*.lst \
    "$OUTPUT_DIR"/iso/boot/grub/x86_64-efi/

echo "set prefix=/boot/grub" > "$OUTPUT_DIR"/iso/boot/grub-early.cfg

grub-mkimage \
    -d "$TARGET_DIR/lib/grub/x86_64-efi/" \
    -c "$OUTPUT_DIR"/iso/boot/grub-early.cfg \
    -o "$OUTPUT_DIR"/iso/efi/boot/bootx64.efi \
    -O x86_64-efi \
    -p "" iso9660 normal search search_fs_file
dd if=/dev/zero of="$OUTPUT_DIR"/iso/boot/efiboot.img count=4096
mkdosfs -n RLXOS-UEFI "$OUTPUT_DIR"/iso/boot/efiboot.img
mmd -i "$OUTPUT_DIR"/iso/boot/efiboot.img ::/EFI
mmd -i "$OUTPUT_DIR"/iso/boot/efiboot.img ::/EFI/BOOT
mcopy -i "$OUTPUT_DIR"/iso/boot/efiboot.img "$OUTPUT_DIR"/iso/efi/boot/bootx64.efi ::/EFI/BOOT

install -vDm0644 /dev/stdin "$OUTPUT_DIR"/iso/boot/grub/grub.cfg << EOF
set default="RLXOS GNU/Linux"
set timeout=10

menuentry "RLXOS GNU/Linux" {
	insmod all_video

	linux /boot/bzImage root=/dev/sr0 rootfs-type=iso9660 live quiet console=ttyS0
	initrd /boot/initramfs.img
}
EOF

install -vDm0644 /dev/stdin "$OUTPUT_DIR"/iso/isolinux/isolinux.cfg << EOF
DEFAULT RLXOS
    LABEL RLXOS
    KERNEL /boot/bzImage
    APPEND initrd=/boot/initramfs.img root=/dev/sr0 rootfs-type=iso9660 live quiet console=ttyS0
EOF

cp "$OUTPUT_DIR"/bzImage \
   "$OUTPUT_DIR"/initramfs.img \
   "$OUTPUT_DIR"/iso/boot/

cp "$OUTPUT_DIR/rootfs.squashfs" \
  "$OUTPUT_DIR/iso/rootfs.sfs"

xorriso -as mkisofs \
    -isohybrid-mbr "$HOST_DIR/share/syslinux/isohdpfx.bin" \
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
    -o "$OUTPUT_DIR"/installer.iso "$OUTPUT_DIR"/iso/

rm -rf "$OUTPUT_DIR"/iso
