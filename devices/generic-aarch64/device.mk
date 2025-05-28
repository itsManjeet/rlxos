export GOARCH 		:= aarch64
export GOOS 		:= linux

TOOLCHAIN_ARCH := aarch64
TOOLCHAIN_TARGET_TRIPLE	:= $(TOOLCHAIN_ARCH)-linux-musl
KERNEL_ARCH := arm64

KERNEL_IMAGE := $(KERNEL_PATH)/arch/$(KERNEL_ARCH)/boot/bzImage
KERNEL_CONFIG_FRAGMENTS += \
	$(DEVICE_PATH)/kernel.config

UEFI_IMAGE := $(IMAGES_PATH)/EFI/BOOT/BOOTX64.EFI
DISK_IMAGE := $(IMAGES_PATH)/disk.img

SYSTEMD_UEFI_BOOT_STUB ?= /usr/lib/systemd/boot/efi/linuxx64.efi.stub
OVMF_CODE_FD ?= /usr/share/OVMF/OVMF_CODE.fd
OVMF_VARS_FD ?= /usr/share/OVMF/OVMF_VARS.fd

all: $(DISK_IMAGE)

run: $(DISK_IMAGE)
	qemu-system-aarch64 -M virt -cpu cortex-a57 -smp 4 -m 2G \
		-drive if=pflash,format=raw,readonly=on,file=$(OVMF_CODE_FD) \
		-drive if=pflash,format=raw,readonly=on,file=$(OVMF_VARS_FD) \
		-drive file=$(DISK_IMAGE),format=raw \
		-vga qxl \
		-vnc :0 \
		-serial tcp::5555,server,nowait

$(UEFI_IMAGE): $(KERNEL_IMAGE) $(INITRAMFS_IMAGE) $(DEVICE_PATH)/cmdline.txt $(SYSTEMD_UEFI_BOOT_STUB)
	@mkdir -p $(shell dirname $@)
	objcopy \
		--add-section .cmdline=$(DEVICE_PATH)/cmdline.txt --change-section-vma .cmdline=0x30000 \
		--add-section .linux=$(KERNEL_IMAGE) --change-section-vma .linux=0x2000000 \
		--add-section .initrd=$(INITRAMFS_IMAGE) --change-section-vma .initrd=0x3000000 \
		$(SYSTEMD_UEFI_BOOT_STUB) $@

$(DISK_IMAGE): $(UEFI_IMAGE) $(SYSTEM_IMAGE) $(DEVICE_PATH)/genimage.cfg
	@rm -rf $(DEVICE_CACHE_PATH)/temp
	PATH=$(PATH):/usr/sbin genimage \
		--rootpath $(IMAGES_PATH) \
		--tmppath $(DEVICE_CACHE_PATH)/temp \
		--inputpath $(IMAGES_PATH) \
		--outputpath $(IMAGES_PATH) \
		--config $(DEVICE_PATH)/genimage.cfg
