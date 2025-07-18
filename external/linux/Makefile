KERNEL_VERSION ?= 6.15.4
KERNEL_PATH = $(DEVICE_CACHE_PATH)/kernel
KERNEL_IMAGE = $(IMAGES_PATH)/kernel.img

$(SOURCES_PATH)/linux-$(KERNEL_VERSION).tar.xz:
	mkdir -p $(shell dirname $@)
	wget -nc https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$(KERNEL_VERSION).tar.xz -P $(shell dirname $@)

$(KERNEL_PATH)/Makefile: $(SOURCES_PATH)/linux-$(KERNEL_VERSION).tar.xz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(KERNEL_PATH)/.config: $(KERNEL_PATH)/Makefile $(KERNEL_CONFIG_FRAGMENTS) $(TOOLCHAIN_PATH)/bin/$(TARGET_TRIPLE)-gcc
ifndef KERNEL_ARCH
$(error KERNEL_ARCH is not defined)
endif
	$(MAKE) -C $(KERNEL_PATH) ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(TARGET_TRIPLE)- defconfig
	KCONFIG_CONFIG=$(KERNEL_PATH)/.config $(KERNEL_PATH)/scripts/kconfig/merge_config.sh -m $(KERNEL_PATH)/.config $(KERNEL_CONFIG_FRAGMENTS)
	$(MAKE) -C $(KERNEL_PATH) ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(TARGET_TRIPLE)- olddefconfig

$(KERNEL_IMAGE): $(KERNEL_PATH)/.config $(TOOLCHAIN_PATH)/bin/$(TARGET_TRIPLE)-gcc
	$(MAKE) -C $(KERNEL_PATH) ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(TARGET_TRIPLE)- -j$(shell nproc)
	cp  $(KERNEL_PATH)/$(shell $(MAKE) -C $(KERNEL_PATH) CROSS_COMPILE=$(TARGET_TRIPLE)- -s image_name) $@