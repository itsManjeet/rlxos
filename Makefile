GO ?= go
GOFLAGS ?=

CACHE_PATH ?= $(CURDIR)/_cache
BUILDROOT_VERSION ?= c40a7ed80a6a86f2c7cb7b95be2262d050d06f65

-include config.mk
ifndef DEVICE
$(error DEVICE is not set)
endif

DEVICE_PATH = $(CURDIR)/devices/$(DEVICE)
DEVICE_CACHE_PATH = $(CACHE_PATH)/$(DEVICE)
include $(DEVICE_PATH)/config.mk

BUILDROOT_PATH = $(CACHE_PATH)/buildroot

BUILDROOT_CACHE_PATH = $(DEVICE_CACHE_PATH)/buildroot
TOOLCHAIN_PATH = $(BUILDROOT_CACHE_PATH)/host
SYSROOT_PATH = $(TOOLCHAIN_PATH)/$(TARGET_TRIPLE)/sysroot

SOURCES_PATH = $(CACHE_PATH)/sources
IMAGES_PATH = $(DEVICE_CACHE_PATH)/images

SYSTEM_PATH = $(DEVICE_CACHE_PATH)/system
SYSTEM_IMAGE = $(IMAGES_PATH)/system.img
SYSTEM_TARGETS += cmd/service cmd/init cmd/shell \
				cmd/compositor cmd/sysctl

INITRAMFS_IMAGE = $(IMAGES_PATH)/initramfs.img

KERNEL_VERSION ?= 6.15.4
KERNEL_PATH = $(DEVICE_CACHE_PATH)/kernel
KERNEL_IMAGE = $(IMAGES_PATH)/kernel.img

INSTALLER_IMAGE = $(IMAGES_PATH)/installer.iso

export PATH := $(TOOLCHAIN_PATH)/bin:$(PATH):/usr/sbin:/sbin

export CC 		= $(TARGET_TRIPLE)-gcc
export CXX 		= $(TARGET_TRIPLE)-g++
export LD 		= $(TARGET_TRIPLE)-ld
export AR 		= $(TARGET_TRIPLE)-ar
export AS 		= $(TARGET_TRIPLE)-as
export RANLIB 	= $(TARGET_TRIPLE)-ranlib
export STRIP 	= $(TARGET_TRIPLE)-strip

export CGO_ENABLED = 0

.PHONY: all clean dist-clean

all: $(INSTALLER_IMAGE)

clean:
	rm -rf $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE)

dist-clean: clean-buildroot clean
	rm -rf $(SYSTEM_PATH) $(INITRAMFS_PATH)

clean-buildroot:
	rm -rf $(BUILDROOT_CACHE_PATH)/target
	rm -rf $(BUILDROOT_CACHE_PATH)/build/skeleton
	rm -rf $(BUILDROOT_CACHE_PATH)/build/skeleton-custom
	rm -rf $(BUILDROOT_CACHE_PATH)/build/skeleton-init-common
	rm -rf $(BUILDROOT_CACHE_PATH)/build/skeleton-init-none

	rm -f $(BUILDROOT_CACHE_PATH)/build/*/.stamp_target_installed
	rm -f $(BUILDROOT_CACHE_PATH)/build/host-gcc-final/.stamp_target_installed

run: $(INSTALLER_IMAGE)
ifndef QEMU
$(error QEMU command is not defined)
endif
	$(QEMU) $(QEMU_ARGS) \
		-cdrom $(INSTALLER_IMAGE) \
		-serial tcp::5555,server,nowait \
		-smp 2 -m 1024

debug-shell:
	go run rlxos.dev/tools/debug shell

buildroot: $(BUILDROOT_CACHE_PATH)/.config
	$(call run-buildroot)

$(SYSTEM_PATH)/%: %/*.go $(TOOLCHAIN_PATH)/bin/go
	GOOS=$(GOOS) GOARCH=$(GOARCH) $(GO) $(GOFLAGS) build -o $@ rlxos.dev/$(shell dirname $<)

$(INITRAMFS_PATH)/%: $(SYSTEM_PATH)/%
	mkdir -p $(INITRAMFS_PATH)/$(shell dirname $(<:$(SYSTEM_PATH)/%=%))
	cp -rap $< $@

$(SYSTEM_PATH)/lib/modules/$(KERNEL_VERSION): $(KERNEL_IMAGE)
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- -j$(shell nproc) \
		INSTALL_MOD_PATH=$(SYSTEM_PATH) INSTALL_MOD_STRIP=1 modules_install

$(SOURCES_PATH)/$(BUILDROOT_VERSION).tar.gz:
	mkdir -p $(shell dirname $@)
	wget -nc https://github.com/itsManjeet/buildroot/archive/$(BUILDROOT_VERSION).tar.gz -P $(shell dirname $@)

$(BUILDROOT_PATH)/Makefile: $(SOURCES_PATH)/$(BUILDROOT_VERSION).tar.gz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

define run-buildroot
make -C $(BUILDROOT_PATH) \
	BR2_DEFCONFIG=$(DEVICE_PATH)/toolchain.config \
	BR2_DL_DIR="$(SOURCES_PATH)" \
	DEVICE_PATH="$(DEVICE_PATH)" \
	DEVICE_CACHE_PATH="$(DEVICE_CACHE_PATH)" \
	PROJECT_PATH="$(CURDIR)" \
	O=$(BUILDROOT_CACHE_PATH) $(1)
endef

$(BUILDROOT_CACHE_PATH)/.config: $(BUILDROOT_PATH)/Makefile $(DEVICE_PATH)/toolchain.config
	$(call run-buildroot,defconfig)

$(SYSROOT_PATH)/%: $(BUILDROOT_CACHE_PATH)/.config
	$(call run-buildroot)

$(TOOLCHAIN_PATH)/bin/go: $(BUILDROOT_CACHE_PATH)/.config
	$(call run-buildroot,host-go)

$(SYSTEM_IMAGE): $(addprefix $(SYSTEM_PATH)/,$(SYSTEM_TARGETS)) $(SYSTEM_PATH)/lib/modules/$(KERNEL_VERSION)
	mkdir -p $(shell dirname $@)
	rsync -a --delete $(CURDIR)/config/ $(SYSTEM_PATH)/config/
	rsync -a --delete $(CURDIR)/data/ $(SYSTEM_PATH)/data/
	rsync -a $(BUILDROOT_CACHE_PATH)/target/lib/ $(SYSTEM_PATH)/lib/
	rsync -a $(BUILDROOT_CACHE_PATH)/target/etc/ $(SYSTEM_PATH)/etc/
	rsync -a $(BUILDROOT_CACHE_PATH)/target/usr/share/ $(SYSTEM_PATH)/data/
	rsync -a $(BUILDROOT_CACHE_PATH)/target/bin/ $(BUILDROOT_CACHE_PATH)/target/sbin/ $(SYSTEM_PATH)/cmd/
	rm -f $(SYSTEM_PATH)/lib64 	&& ln -sfv lib $(SYSTEM_PATH)/lib64
	rm -f $(SYSTEM_PATH)/usr 	&& ln -sfv . $(SYSTEM_PATH)/usr
	rm -f $(SYSTEM_PATH)/share 	&& ln -sfv data $(SYSTEM_PATH)/share
	depmod -a -b $(SYSTEM_PATH) $(KERNEL_VERSION)
	mksquashfs $(SYSTEM_PATH) $@ -noappend -all-root

$(INITRAMFS_IMAGE): $(SYSTEM_IMAGE)
	IMAGES_PATH=$(IMAGES_PATH) SYSTEM_PATH=$(SYSTEM_PATH) \
		$(CURDIR)/tools/mkinitramfs.sh $@

$(KERNEL_PATH)/Makefile: $(SOURCES_PATH)/linux/linux-$(KERNEL_VERSION).tar.xz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(KERNEL_PATH)/.config: $(KERNEL_PATH)/Makefile $(KERNEL_CONFIG_FRAGMENTS)
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- defconfig
	KCONFIG_CONFIG=$(KERNEL_PATH)/.config $(KERNEL_PATH)/scripts/kconfig/merge_config.sh -m $(KERNEL_PATH)/.config $(KERNEL_CONFIG_FRAGMENTS)
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- olddefconfig

$(KERNEL_IMAGE): $(KERNEL_PATH)/.config
	mkdir -p $(shell dirname $@)
	$(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- -j$(shell nproc)
	cp  $(KERNEL_PATH)/$(shell $(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- -s image_name) $@

$(INSTALLER_IMAGE): $(SYSTEM_IMAGE) $(INITRAMFS_IMAGE) $(KERNEL_IMAGE) $(CURDIR)/tools/genimage.sh
	IMAGES_PATH=$(IMAGES_PATH) TARGET_PATH=$(BUILDROOT_CACHE_PATH)/target \
		HOST_PATH=$(BUILDROOT_CACHE_PATH)/host $(CURDIR)/tools/genimage.sh

include $(shell find $(CURDIR) -type f -name "Makefile" -not -path "$(CURDIR)/Makefile" -not -path "$(CURDIR)/devices/*")
-include $(DEVICE_PATH)/Makefile