#!/bin/sh

qemu-system-x86_64 -m 4G		\
	-vga virtio	\
	-display default	\
	-usb		\
	-device usb-tablet \
	-smp 2		\
	-cdrom $1	\
	-cpu host \
	-enable-kvm
