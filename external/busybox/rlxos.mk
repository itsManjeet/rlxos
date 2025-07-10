BUSYBOX_VERSION ?= 1.37.0

$(SOURCES_PATH)/busybox-$(BUSYBOX_VERSION).tar.bz2:
	wget -nc https://busybox.net/downloads/busybox-$(BUSYBOX_VERSION).tar.bz2 -P $(shell dirname $@)

$(BUILD_PATH)/busybox-$(BUSYBOX_VERSION)/Makefile: $(SOURCES_PATH)/busybox-$(BUSYBOX_VERSION).tar.bz2
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(BUILD_PATH)/busybox-$(BUSYBOX_VERSION)/.config: $(TOOLCHAIN_PATH)/bin/$(TARGET_TRIPLE)-gcc $(BUILD_PATH)/busybox-$(BUSYBOX_VERSION)/Makefile
	$(MAKE) -C $(shell dirname $@) CROSS_COMPILE=$(TARGET_TRIPLE)- defconfig

$(BUILD_PATH)/busybox-$(BUSYBOX_VERSION)/busybox: $(BUILD_PATH)/busybox-$(BUSYBOX_VERSION)/.config
	$(MAKE) -C $(shell dirname $@) CROSS_COMPILE=$(TARGET_TRIPLE)-

$(SYSTEM_PATH)/cmd/busybox: $(BUILD_PATH)/busybox-$(BUSYBOX_VERSION)/busybox
	mkdir -p $(shell dirname $@)
	cp -rap $< $@
