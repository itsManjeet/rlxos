LIMINE_VERSION ?= 9.5.0

$(SOURCES_PATH)/limine-$(LIMINE_VERSION).tar.gz:
	wget -nc https://github.com/limine-bootloader/limine/releases/download/v$(LIMINE_VERSION)/limine-$(LIMINE_VERSION).tar.gz -P $(shell dirname $@)

$(BUILD_PATH)/limine-$(LIMINE_VERSION)/Makefile: $(SOURCES_PATH)/limine-$(LIMINE_VERSION).tar.gz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(BUILD_PATH)/limine-$(LIMINE_VERSION)/limine: $(BUILD_PATH)/limine-$(LIMINE_VERSION)/Makefile
	$(MAKE) -C $(shell dirname $@) limine

$(TOOLCHAIN_PATH)/bin/limine: $(BUILD_PATH)/limine-$(LIMINE_VERSION)/limine
	cp $< $@