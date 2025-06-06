export GOARCH 		:= amd64
export GOOS 		:= linux

TOOLCHAIN_ARCH := x86_64
TOOLCHAIN_TARGET_TRIPLE	:= $(TOOLCHAIN_ARCH)-linux-musl
KERNEL_ARCH := x86_64

KERNEL_IMAGE := $(KERNEL_PATH)/arch/x86/boot/bzImage
KERNEL_CONFIG_FRAGMENTS += \
	$(DEVICE_PATH)/kernel.config

CFLAGS += -march=x86-64
CXXFLAGS += -march=x86-64

all: $(SYSTEM_IMAGE) $(KERNEL_IMAGE) $(INITRAMFS_IMAGE)

run: $(SYSTEM_IMAGE) $(KERNEL_IMAGE) $(INITRAMFS_IMAGE)
	qemu-system-x86_64 -enable-kvm -smp 2 -m 1G \
		-cpu host \
		-kernel $(KERNEL_IMAGE) -initrd $(INITRAMFS_IMAGE) \
		-append '-rootfs=/dev/sda console=ttyS0' \
		-drive file=$(SYSTEM_IMAGE),format=raw \
		-vga qxl
