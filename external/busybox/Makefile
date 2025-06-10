BUSYBOX_VERSION ?= 1.36.1
BUSYBOX_PATH := $(DEVICE_CACHE_PATH)/busybox
BUSYBOX_IMAGE := $(BUSYBOX_PATH)/busybox
BUSYBOX_CONFIG := $(CURDIR)/external/busybox/config

$(SYSTEM_PATH)/cmd/busybox: $(BUSYBOX_IMAGE)
	cp -rap $< $@

$(CACHE_PATH)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget -nc https://www.busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2 -P $(shell dirname $@)

$(BUSYBOX_PATH)/Makefile: $(CACHE_PATH)/busybox-$(BUSYBOX_VERSION).tar.bz2
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(BUSYBOX_IMAGE): $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc $(BUSYBOX_PATH)/Makefile $(BUSYBOX_CONFIG)
	cp $(BUSYBOX_CONFIG) $(BUSYBOX_PATH)/.config
	$(MAKE) -C $(BUSYBOX_PATH) ARCH=$(KERNEL_ARCH) CROSS_COMPILE=$(TOOLCHAIN_TARGET_TRIPLE)-
