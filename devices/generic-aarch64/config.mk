export GOARCH 		:= amd64
export GOOS 		:= linux

TARGET_TRIPLE := aarch64-linux-musl

QEMU := qemu-system-aarch64
QEMU_ARGS += \

KERNEL_CONFIG_FRAGMENTS += \
	$(CURDIR)/devices/common/kernel.config \
	$(DEVICE_PATH)/kernel.config