export GOARCH 		:= amd64
export GOOS 		:= linux

TARGET_TRIPLE := x86_64-linux-musl

QEMU := qemu-system-x86_64
QEMU_ARGS += \
	-bios $(DEVICE_PATH)/firmware