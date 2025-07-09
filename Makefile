GO ?= go
GOFLAGS ?=

CACHE_PATH ?= $(CURDIR)/_cache

-include config.mk
ifndef DEVICE
$(error DEVICE is not set)
endif

DEVICE_PATH = $(CURDIR)/devices/$(DEVICE)
DEVICE_CACHE_PATH = $(CACHE_PATH)/$(DEVICE)
include $(DEVICE_PATH)/config.mk

TOOLCHAIN_PATH = $(DEVICE_CACHE_PATH)/toolchain
SYSROOT_PATH = $(TOOLCHAIN_PATH)/$(TARGET_TRIPLE)/sysroot

SOURCES_PATH = $(CACHE_PATH)/sources
IMAGES_PATH = $(DEVICE_CACHE_PATH)/images

SYSTEM_PATH = $(DEVICE_CACHE_PATH)/system
SYSTEM_IMAGE = $(IMAGES_PATH)/system.img
SYSTEM_TARGETS += cmd/init cmd/service cmd/shell

INITRAMFS_IMAGE = $(IMAGES_PATH)/initramfs.img
INITRAMFS_PATH = $(DEVICE_CACHE_PATH)/initramfs
INITRAMFS_TARGETS += init

KERNEL_VERSION ?= 6.15.4
KERNEL_PATH = $(DEVICE_CACHE_PATH)/kernel
KERNEL_IMAGE = $(IMAGES_PATH)/kernel.img

export PATH := $(TOOLCHAIN_PATH)/bin:$(PATH)

export CC 		= $(TARGET_TRIPLE)-gcc
export CXX 		= $(TARGET_TRIPLE)-g++
export LD 		= $(TARGET_TRIPLE)-ld
export AR 		= $(TARGET_TRIPLE)-ar
export AS 		= $(TARGET_TRIPLE)-as
export RANLIB 	= $(TARGET_TRIPLE)-ranlib
export STRIP 	= $(TARGET_TRIPLE)-strip

export CGO_ENABLED = 0

.PHONY: all clean dist-clean

all: $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE) $(KERNEL_IMAGE)

clean:
	rm -rf $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE) $(KERNEL_IMAGE)
	rm -rf $(SYSTEM_PATH) $(INITRAMFS_PATH)

run: $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE) $(KERNEL_IMAGE)
ifndef QEMU
$(error QEMU command is not defined)
endif
	$(QEMU) $(QEMU_ARGS) \
		-kernel $(KERNEL_IMAGE) \
		-initrd $(INITRAMFS_IMAGE) \
		-append '$(shell cat $(DEVICE_PATH)/cmdline.txt)' \
		-drive file=$(SYSTEM_IMAGE),format=raw \
		-serial tcp::5555,server,nowait \
		-smp 2 -m 512M

debug-shell:
	go run rlxos.dev/tools/debug shell

$(SYSTEM_PATH)/%: %/*.go
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) $(GOFLAGS) build -o $@ rlxos.dev/$(shell dirname $<)

$(INITRAMFS_PATH)/%: $(SYSTEM_PATH)/%
	mkdir -p $(INITRAMFS_PATH)/$(shell dirname $(<:$(SYSTEM_PATH)/%=%))
	cp -rap $< $@

$(SOURCES_PATH)/$(TARGET_TRIPLE)-cross.tgz:
	mkdir -p $(shell dirname $@)
	wget -nc https://musl.cc/$(TARGET_TRIPLE)-cross.tgz -P $(shell dirname $@)


$(TOOLCHAIN_PATH)/bin/$(TARGET_TRIPLE)-gcc: $(SOURCES_PATH)/$(TARGET_TRIPLE)-cross.tgz
	mkdir -p $(TOOLCHAIN_PATH)
	tar -xmf $< -C $(TOOLCHAIN_PATH) --strip-components=1

$(SYSTEM_IMAGE): $(addprefix $(SYSTEM_PATH)/,$(SYSTEM_TARGETS))
	mkdir -p $(shell dirname $@)
	rsync -a --delete $(CURDIR)/config/ $(SYSTEM_PATH)/config/
	rsync -a --delete $(CURDIR)/data/ $(SYSTEM_PATH)/data/
	mksquashfs $(SYSTEM_PATH) $@ -noappend -all-root

$(INITRAMFS_PATH)/init: $(SYSTEM_PATH)/cmd/init
	mkdir -p $(shell dirname $@)
	cp -rap $< $@

$(INITRAMFS_IMAGE): $(addprefix $(INITRAMFS_PATH)/,$(INITRAMFS_TARGETS))
	@mkdir -p $(shell dirname $@)
	(cd $(INITRAMFS_PATH) && find . -print0 | cpio --null -ov --format=newc --quiet) 2>/dev/null > $@

$(SOURCES_PATH)/linux-$(KERNEL_VERSION).tar.xz:
	mkdir -p $(shell dirname $@)
	wget -nc https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$(KERNEL_VERSION).tar.xz -P $(shell dirname $@)

$(KERNEL_PATH)/Makefile: $(SOURCES_PATH)/linux-$(KERNEL_VERSION).tar.xz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(KERNEL_PATH)/.config: $(KERNEL_PATH)/Makefile $(KERNEL_CONFIG_FRAGMENTS) $(TOOLCHAIN_PATH)/bin/$(TARGET_TRIPLE)-gcc
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- defconfig
	KCONFIG_CONFIG=$(KERNEL_PATH)/.config $(KERNEL_PATH)/scripts/kconfig/merge_config.sh -m $(KERNEL_PATH)/.config $(KERNEL_CONFIG_FRAGMENTS)
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- olddefconfig

$(KERNEL_IMAGE): $(KERNEL_PATH)/.config $(TOOLCHAIN_PATH)/bin/$(TARGET_TRIPLE)-gcc
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- -j$(shell nproc)
	cp  $(KERNEL_PATH)/$(shell $(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- -s image_name) $@

	
include $(shell find . -type f -name "*rlxos.inc")