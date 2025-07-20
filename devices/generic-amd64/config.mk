export GOARCH = amd64
export GOOS   = linux

TARGET_TRIPLE = x86_64-rlxos-linux-musl
KERNEL_BZIMAGE = arch/x86/boot/bzImage
KERNEL_CONFIG_FRAGMENTS += $(DEVICE_PATH)/kernel.config

QEMU = qemu-system-x86_64
QEMU_ARGS += 

CFLAGS 		+= -march=x86_64
CXXFLAGS 	+= -march=x86_64