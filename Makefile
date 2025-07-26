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
SYSROOT_PATH = $(TOOLCHAIN_PATH)/$(TARGET_TRIPLE)

SOURCES_PATH = $(CACHE_PATH)/sources
IMAGES_PATH = $(DEVICE_CACHE_PATH)/images
BUILD_PATH = $(DEVICE_CACHE_PATH)/build

SYSTEM_PATH = $(DEVICE_CACHE_PATH)/system
SYSTEM_IMAGE = $(IMAGES_PATH)/system.img
SYSTEM_TARGETS += cmd/init \
				cmd/service \
				cmd/shell \
				cmd/sysctl \
				cmd/module \
				cmd/busybox \
				service/display \
				service/udevd \
				apps/welcome \
				apps/console \
				lib/modules \
				lib/libc.so \
				lib/ld-musl-x86_64.so.1

INITRAMFS_IMAGE = $(IMAGES_PATH)/initramfs.img
INITRAMFS_PATH = $(DEVICE_CACHE_PATH)/initramfs
INITRAMFS_TARGETS += init

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

debug-shell:
	GOOS=linux GOARCH=amd64 go run rlxos.dev/tools/debug shell

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
	
include $(shell find $(CURDIR)/ -type f -name "Makefile" -not -path "$(CURDIR)/Makefile" -not -path "$(CURDIR)/devices/*")
-include $(DEVICE_PATH)/Makefile