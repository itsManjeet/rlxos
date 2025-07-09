export GOARCH 		:= amd64
export GOOS 		:= linux
export CFLAGS 		+= -march=x86-64
export CXXFLAGS		+= -march=x86-64


TARGET_TRIPLE := x86_64-linux-musl
KERNEL_ARCH := x86_64


QEMU := qemu-system-x86_64
QEMU_ARGS += \

KERNEL_CONFIG_FRAGMENTS += \
	$(CURDIR)/devices/common/kernel.config \
	$(DEVICE_PATH)/kernel.config