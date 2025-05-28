GO ?= go
GOFLAGS ?=
CACHE_PATH ?= $(CURDIR)/_cache

-include config.mk

ifndef DEVICE
$(error DEVICE not specified)
endif

DEVICE_PATH := $(CURDIR)/devices/$(DEVICE)
DEVICE_CACHE_PATH := $(CACHE_PATH)/$(DEVICE)

IMAGES_PATH := $(DEVICE_CACHE_PATH)/images/

SYSTEM_PATH := $(DEVICE_CACHE_PATH)/system
SYSTEM_IMAGE := $(IMAGES_PATH)/system.img
SYSTEM_TARGETS := cmd/init \
				cmd/service \
				cmd/capsule \
				cmd/busybox \
				service/udevd \
				cmd/display service/display \
				cmd/shell service/shell \
				apps/welcome

ASSETS_TARGETS := $(shell find $(CURDIR)/config -type f) $(shell find $(CURDIR)/data -type f)

INITRAMFS_PATH := $(DEVICE_CACHE_PATH)/initramfs
INITRAMFS_IMAGE := $(IMAGES_PATH)/initramfs.img
INITRAMFS_TARGETS := cmd/init

KERNEL_VERSION ?= 6.14.6
KERNEL_PATH := $(DEVICE_CACHE_PATH)/kernel
KERNEL_CONFIG_FRAGMENTS := $(CURDIR)/devices/common/kernel.config

BUSYBOX_VERSION ?= 1.36.1
BUSYBOX_PATH := $(DEVICE_CACHE_PATH)/busybox
BUSYBOX_IMAGE := $(BUSYBOX_PATH)/busybox
BUSYBOX_CONFIG := $(CURDIR)/devices/common/busybox.config

include $(DEVICE_PATH)/device.mk

TOOLCHAIN_PATH := $(DEVICE_CACHE_PATH)/toolchain
SYSROOT_PATH := $(TOOLCHAIN_PATH)/$(TOOLCHAIN_TARGET_TRIPLE)

SYSTEM_TARGETS += \
	lib/libc.so \
	lib/ld-musl-$(TOOLCHAIN_ARCH).so.1 \

include tools/toolchain.mk

include $(wildcard external/*/*.mk)

ifndef KERNEL_IMAGE
$(error KERNEL_IMAGE not set)
endif

SYSTEM_TARGETS := $(addprefix $(SYSTEM_PATH)/,$(SYSTEM_TARGETS))
INITRAMFS_TARGETS := $(addprefix $(INITRAMFS_PATH)/,$(INITRAMFS_TARGETS))

docs:
	$(GO) tool golang.org/x/tools/cmd/godoc -http=:6060 .

clean:
	rm -f $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE)
	rm -rf $(SYSTEM_PATH) $(INITRAMFS_PATH)

clean-kernel-image:
	rm -f $(KERNEL_IMAGE)

clean-busybox-image:
	rm -f $(BUSYBOX_IMAGE)

test:
	go test ./...

$(SYSTEM_PATH)/cmd/busybox: $(BUSYBOX_IMAGE)
	cp -rap $< $@

$(SYSTEM_PATH)/lib/libc.so: $(SYSROOT_PATH)/lib/libc.so
	mkdir -p $(shell dirname $@)
	cp -rap $< $@

$(SYSTEM_PATH)/lib/ld-musl-$(TOOLCHAIN_ARCH).so.1: $(SYSTEM_PATH)/lib/libc.so
	ln -sfv libc.so $@

$(SYSTEM_PATH)/cmd/ldd: $(SYSTEM_PATH)/lib/libc.so
	ln -sfv libc.so $@

$(SYSTEM_PATH)/%: %/*.go
	$(GO) $(GOFLAGS) build -o $@ rlxos.dev/$(shell dirname $<)

$(SYSTEM_IMAGE): $(SYSTEM_PATH)/lib/libc.so $(SYSTEM_TARGETS) $(ASSETS_TARGETS)
	rsync -au --delete $(CURDIR)/config/ $(SYSTEM_PATH)/config/
	rsync -au --delete $(CURDIR)/data/ $(SYSTEM_PATH)/data/
	@mkdir -p $(shell dirname $@)
	mksquashfs $(SYSTEM_PATH) $@ -noappend -all-root

$(INITRAMFS_PATH)/%: $(SYSTEM_PATH)/%
	mkdir -p $(INITRAMFS_PATH)/$(shell dirname $(<:$(SYSTEM_PATH)/%=%))
	cp -rap $< $@

$(INITRAMFS_IMAGE): $(INITRAMFS_TARGETS)
	ln -sfv cmd/init $(INITRAMFS_PATH)/init
	@mkdir -p $(shell dirname $@)
	(cd $(INITRAMFS_PATH) && find . -print0 | cpio --null -ov --format=newc --quiet) 2>/dev/null > $@

$(CACHE_PATH)/linux-$(KERNEL_VERSION).tar.xz:
	wget -nc https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$(KERNEL_VERSION).tar.xz -P $(shell dirname $@)

$(KERNEL_PATH)/Makefile: $(CACHE_PATH)/linux-$(KERNEL_VERSION).tar.xz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(KERNEL_IMAGE): $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc $(KERNEL_PATH)/Makefile $(KERNEL_CONFIG_FRAGMENTS)
	$(MAKE) -C $(KERNEL_PATH) ARCH=$(TOOLCHAIN_ARCH) CROSS_COMPILE=$(TOOLCHAIN_TARGET_TRIPLE)- defconfig
	KCONFIG_CONFIG=$(KERNEL_PATH)/.config $(KERNEL_PATH)/scripts/kconfig/merge_config.sh -m $(KERNEL_PATH)/.config $(KERNEL_CONFIG_FRAGMENTS)
	$(MAKE) -C $(KERNEL_PATH) ARCH=$(TOOLCHAIN_ARCH) CROSS_COMPILE=$(TOOLCHAIN_TARGET_TRIPLE)- olddefconfig
	$(MAKE) -C $(KERNEL_PATH) ARCH=$(TOOLCHAIN_ARCH) CROSS_COMPILE=$(TOOLCHAIN_TARGET_TRIPLE)- -j$(shell nproc)

$(CACHE_PATH)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget -nc https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2 -P $(shell dirname $@)

$(BUSYBOX_PATH)/Makefile: $(CACHE_PATH)/busybox-$(BUSYBOX_VERSION).tar.bz2
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(BUSYBOX_IMAGE): $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc $(BUSYBOX_PATH)/Makefile $(BUSYBOX_CONFIG)
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_PATH)/.config
	$(MAKE) -C $(BUSYBOX_PATH) ARCH=$(TOOLCHAIN_ARCH) CROSS_COMPILE=$(TOOLCHAIN_TARGET_TRIPLE)-

$(CACHE_PATH)/$(TOOLCHAIN_TARGET_TRIPLE)-cross.tgz:
	wget -nc https://musl.cc/x86_64-linux-musl-cross.tgz -P $(CACHE_PATH)

$(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc: $(CACHE_PATH)/$(TOOLCHAIN_TARGET_TRIPLE)-cross.tgz
	mkdir -p $(TOOLCHAIN_PATH)
	tar -xmf $< -C $(TOOLCHAIN_PATH) --strip-components=1

$(SYSROOT_PATH)/lib/libc.so: $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc