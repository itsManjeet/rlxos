SYSTEM_IMAGE 		?= ${IMAGES_PATH}/system.img
RAMDISK_IMAGE 		?= ${IMAGES_PATH}/ramdisk.img
ISO_IMAGE			?= ${IMAGES_PATH}/installer.iso

ISO_IMAGE_PATH		?= ${IMAGES_PATH}/iso

RAMDISK_TARGETS 	+= init cmd/busybox
RAMDISK_TARGETS		+= cmd/udevd cmd/udevadm
RAMDISK_TARGETS 	+= lib/libc.so lib/ld-musl-${TARGET_MACHINE}.so.1

KERNEL_SUBSYSTEMS 	+= crypto fs lib
KERNEL_DRIVERS 		+= block md firewire nvme parport input scsi message virtio hid usb/host usb/storage

KERNEL_VERSION		?= $(shell ls ${SYSROOT_PATH}/lib/modules/ -1 | head -n 1)
KERNEL_MODULES_PATH	:= $(addprefix ${SYSROOT_PATH}/lib/modules/${KERNEL_VERSION}/kernel/,${KERNEL_SUBSYSTEMS})
KERNEL_MODULES_PATH	:= $(addprefix ${SYSROOT_PATH}/lib/modules/${KERNEL_VERSION}/kernel/drivers/,${KERNEL_DRIVERS})

KERNEL_MODULES 		:= $(shell find ${KERNEL_MODULES_PATH} -type f -name "*.ko*")
RAMDISK_TARGETS		+= ${KERNEL_MODULES:${SYSROOT_PATH}/%=/%}

UDEVD_RULES			+= $(shell find ${SYSROOT_PATH}/lib/udev/ -type f)
RAMDISK_TARGETS		+= ${UDEVD_RULES:${SYSROOT_PATH}/%=/%}

HOST_PATH			:= ${.BUILDDIR}/build/buildroot/host

SYSLINUX_MODULES	:= chain.c32 isolinux.bin isolinux.bin ldlinux.c32 libutil.c32 reboot.c32 vesamenu.c32 libcom32.c32 poweroff.c32
ISO_TARGETS			+= $(addprefix ${ISO_IMAGE_PATH}/isolinux/,${SYSLINUX_MODULES})

GRUB_MODULES 		:= $(shell find ${HOST_PATH}/lib/grub/ -type f -name "*.mod" -o -name "*.lst")
ISO_TARGETS			+= ${GRUB_MODULES:${HOST_PATH}/lib/%=${ISO_IMAGE_PATH}/iso/boot/%}

ISO_TARGETS			+= ${ISO_IMAGE_PATH}/boot/grub/grub.cfg
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/efi/boot/bootx64.efi
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/system.img
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/boot/ramdisk.img
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/boot/kernel.img
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/isolinux/isolinux.cfg
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/boot/grub/grub.cfg
ISO_TARGETS			+= ${ISO_IMAGE_PATH}/boot/efiboot.img

all: ${ISO_IMAGE} ${ISO_IMAGE}.zsync

clean:

install:

compile_db:

fetch_sources:

${SYSTEM_IMAGE}:
	mksquashfs ${SYSROOT_PATH} $@ -noappend -all-root

${RAMDISK_PATH}/%: ${SYSROOT_PATH}/%
	@mkdir -p $(dir $@)
	cp -a $< $@

${RAMDISK_PATH}/init: ${SYSROOT_PATH}/cmd/init
	@mkdir -p $(dir $@)
	cp -a $< $@

${RAMDISK_PATH}/lib/ld-musl-${TARGET_MACHINE}.so.1: ${RAMDISK_PATH}/lib/libc.so
	ln -sf libc.so $@

${RAMDISK_IMAGE}: $(addprefix ${RAMDISK_PATH}/,${RAMDISK_TARGETS})
	cd ${RAMDISK_PATH} && find . | cpio -H newc -o > $@

${ISO_IMAGE_PATH}/isolinux/%: ${HOST_PATH}/share/syslinux/%
	@mkdir -p $(dir $@)
	cp -a $< $@

${ISO_IMAGE_PATH}/boot/grub/%: ${SYSROOT_PATH}/lib/grub/%
	@mkdir -p $(dir $@)
	cp -a $< $@

${ISO_IMAGE_PATH}/boot/grub-early.cfg:
	@mkdir -p $(dir $@)
	echo "set prefix=/boot/grub" > $@

${ISO_IMAGE_PATH}/efi/boot/bootx64.efi: ${ISO_IMAGE_PATH}/boot/grub/grub.cfg
	@mkdir -p $(dir $@)
	grub-mkimage \
		-d ${HOST_PATH}/../target/lib/grub/x86_64-efi \
		-c ${ISO_IMAGE_PATH}/boot/grub/grub.cfg \
		-o $@ \
		-O x86_64-efi \
		-p "" iso9660 normal search search_fs_file

${ISO_IMAGE_PATH}/boot/efiboot.img: ${ISO_IMAGE_PATH}/efi/boot/bootx64.efi
	dd if=/dev/zero of=$@ count=4096
	mkdosfs -n RLXOS-UEFI $@
	mmd -i $@ ::/EFI
	mmd -i $@ ::/EFI/BOOT
	mcopy -i $@ $< ::/EFI/BOOT/BOOTX64.EFI

${ISO_IMAGE_PATH}/%.img: ${IMAGES_PATH}/%.img
	cp -a $< $@

${ISO_IMAGE_PATH}/boot/%.img: ${IMAGES_PATH}/%.img
	cp -a $< $@

define GRUB_CONFIG
set default="RLXOS"
set timeout=5

menuentry "RLXOS" {
	linux /boot/kernel.img root=/dev/sr0 rootfs-type=iso9660 live console=ttyS0 console=tty0
	initrd /boot/ramdisk.img
}
endef

export GRUB_CONFIG
${ISO_IMAGE_PATH}/boot/grub/grub.cfg:
	@mkdir -p $(dir $@)
	@printf "%s\n" "$$GRUB_CONFIG" > $@

define ISOLINUX_CFG
DEFAULT RLXOS
	LABEL RLXOS
	KERNEL /boot/kernel.img
	APPEND initrd=/boot/ramdisk.img root=/dev/sr0 rootfs-type=iso9660 live console=ttyS0 console=tty0
endef
export ISOLINUX_CFG

${ISO_IMAGE_PATH}/isolinux/isolinux.cfg:
	@mkdir -p $(dir $@)
	@printf "%s\n" "$$ISOLINUX_CFG" > $@

${ISO_IMAGE}: ${ISO_TARGETS}
	@mkdir -p $(dir $@)
	xorriso -as mkisofs \
		-isohybrid-mbr ${HOST_PATH}/share/syslinux/isohdpfx.bin \
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
  		-o $@ ${ISO_IMAGE_PATH}

${ISO_IMAGE}.zsync: ${ISO_IMAGE}
	zsyncmake -b 2048 -C -u ${SERVER_BASE_URL}/$(notdir $<) $< -o $@

.PHONY: ${SYSTEM_IMAGE} ${RAMDISK_IMAGE} ${ISO_IMAGE} ${KERNEL_IMAGE}
