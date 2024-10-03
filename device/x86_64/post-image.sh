#!/bin/sh

BOARD_DIR=$(dirname "$0")

set -e

mkdir -p $BINARIES_DIR/iso/boot/grub/x86_64-efi
mkdir -p $BINARIES_DIR/iso/boot/grub/fonts
mkdir -p $BINARIES_DIR/iso/efi/boot
mkdir -p $BINARIES_DIR/iso/isolinux

for file in chain.c32 isolinux.bin isolinux.bin ldlinux.c32 libutil.c32 reboot.c32 vesamenu.c32 libcom32.c32 poweroff.c32 ; do
    cp "$HOST_DIR/share/syslinux/$file" $BINARIES_DIR/iso/isolinux
done

[ -f "$HOST_DIR/share/grub/unicode.pf2" ] && cp "$HOST_DIR/share/grub/unicode.pf2" $BINARIES_DIR/iso/boot/grub/fonts/

echo "set prefix=/boot/grub" > $BINARIES_DIR/iso/boot/grub-early.cfg
cp -a $TARGET_DIR/lib/grub/x86_64-efi/*.mod \
    $TARGET_DIR/lib/grub/x86_64-efi/*.lst \
    $BINARIES_DIR/iso/boot/grub/x86_64-efi/

echo "set prefix=/boot/grub" > $BINARIES_DIR/iso/boot/grub-early.cfg

grub-mkimage \
    -d "$TARGET_DIR/lib/grub/x86_64-efi/" \
    -c $BINARIES_DIR/iso/boot/grub-early.cfg \
    -o $BINARIES_DIR/iso/efi/boot/bootx64.efi \
    -O x86_64-efi \
    -p "" iso9660 normal search search_fs_file
dd if=/dev/zero of=$BINARIES_DIR/iso/boot/efiboot.img count=4096
mkdosfs -n RLXOS-UEFI $BINARIES_DIR/iso/boot/efiboot.img
mmd -i $BINARIES_DIR/iso/boot/efiboot.img ::/EFI
mmd -i $BINARIES_DIR/iso/boot/efiboot.img ::/EFI/BOOT 
mcopy -i $BINARIES_DIR/iso/boot/efiboot.img $BINARIES_DIR/iso/efi/boot/bootx64.efi ::/EFI/BOOT

cat "$BOARD_DIR/grub.cfg" > $BINARIES_DIR/iso/boot/grub/grub.cfg
cat "$BOARD_DIR/isolinux.cfg" > $BINARIES_DIR/iso/isolinux/isolinux.cfg

cp $BINARIES_DIR/bzImage \
   $BINARIES_DIR/initramfs.img \
   $BINARIES_DIR/iso/boot/

cp $BINARIES_DIR/rootfs.squashfs \
   $BINARIES_DIR/iso/rootfs.sfs

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
    -o $BINARIES_DIR/installer.iso $BINARIES_DIR/iso/

rm -rf $BINARIES_DIR/iso