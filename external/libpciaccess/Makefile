LIBPCIACCESS_VERSION ?= 0.18.1
LIBPCIACCESS_PATH := $(DEVICE_CACHE_PATH)/external/libpciaccess

LIBPCIACCESS_OPTIONS =
LIBPCIACCESS_LIBRARIES = libpciaccess.so

libpciaccess: $(SYSROOT_PATH)/lib/libciaccess.so

clean-libpciaccess-build:
	rm -rf $(LIBPCIACCESS_PATH)/build

clean-libpciaccess:
	rm -rf $(LIBPCIACCESS_PATH)

$(SYSTEM_PATH)/lib/libpciaccess.so: $(SYSROOT_PATH)/lib/libpciaccess.so
	cp -rapL $< $@

$(CACHE_PATH)/libpciaccess-$(LIBPCIACCESS_VERSION).tar.xz:
	wget -nc https://xorg.freedesktop.org/releases/individual/lib/libpciaccess-$(LIBPCIACCESS_VERSION).tar.xz -P $(shell dirname $@)

$(LIBPCIACCESS_PATH)/meson.build: $(CACHE_PATH)/libpciaccess-$(LIBPCIACCESS_VERSION).tar.xz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(LIBPCIACCESS_PATH)/build/build.ninja: $(MESON_TOOLCHAIN_FILE) $(LIBPCIACCESS_PATH)/meson.build
	cd $(LIBPCIACCESS_PATH) && meson setup --cross-file $(MESON_TOOLCHAIN_FILE) $(shell dirname $@) --prefix=/ $(LIBPCIACCESS_OPTIONS)

$(SYSROOT_PATH)/lib/libpciaccess.so: $(LIBPCIACCESS_PATH)/build/build.ninja
	ninja -C $(shell dirname $<)
	DESTDIR=$(SYSROOT_PATH) ninja -C $(shell dirname $<) install