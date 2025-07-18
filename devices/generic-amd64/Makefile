QEMU := qemu-system-x86_64
QEMU_ARGS += \

ifdef INCLUDE_UNIX_COMPONENTS
SYSTEM_TARGETS += cmd/busybox \
				lib/libc.so \
				lib/ld-linux-x86_64.so.1
endif

run: $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE) $(KERNEL_IMAGE)
	$(QEMU) $(QEMU_ARGS) \
		-kernel $(KERNEL_IMAGE) \
		-initrd $(INITRAMFS_IMAGE) \
		-append '$(shell cat $(DEVICE_PATH)/cmdline.txt)' \
		-drive file=$(SYSTEM_IMAGE),format=raw \
		-serial tcp::5555,server,nowait \
		-smp 2 -m 512M
