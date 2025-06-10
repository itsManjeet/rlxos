LIBDRM_VERSION ?= 2.4.124
LIBDRM_PATH := $(DEVICE_CACHE_PATH)/external/libdrm

LIBDRM_OPTIONS =
LIBDRM_DEPENDENCIES =

ifdef LIBDRM
LIBDRM_LIBRARIES += libpciaccess.so libdrm.so
endif

ifdef LIBDRM_INTEL
LIBDRM_OPTIONS += -D intel=enabled
LIBDRM_LIBRARIES += libdrm_intel.so
LIBDRM_DEPENDENCIES += $(SYSTEM_PATH)/lib/libpciaccess.so
else
LIBDRM_OPTIONS += -D intel=disabled
endif

ifdef LIBDRM_RADEON
LIBDRM_OPTIONS += -D radeon=enabled
LIBDRM_LIBRARIES += libdrm_radeon.so
else
LIBDRM_OPTIONS += -D radeon=disabled
endif

ifdef LIBDRM_AMDGPU
LIBDRM_OPTIONS += -D amdgpu=enabled
LIBDRM_LIBRARIES += libdrm_amdgpu.so
else
LIBDRM_OPTIONS += -D amdgpu=disabled
endif

ifdef LIBDRM_NOUVEAU
LIBDRM_OPTIONS += -D nouveau=enabled
LIBDRM_LIBRARIES += libdrm_nouveau.so
else
LIBDRM_OPTIONS += -D nouveau=disabled
endif

ifdef LIBDRM_LIBVMGFX
LIBDRM_OPTIONS += -D vmwgfx=enabled
LIBDRM_LIBRARIES += libdrm_libvmgfx.so
else
LIBDRM_OPTIONS += -D vmwgfx=disabled
endif

SYSTEM_TARGETS += $(addprefix lib/,$(LIBDRM_LIBRARIES))

libdrm: $(SYSROOT_PATH)/lib/libdrm.so

clean-libdrm-build:
	rm -rf $(LIBDRM_PATH)/build

clean-libdrm:
	rm -rf $(LIBDRM_PATH)

$(SYSTEM_PATH)/lib/libdrm.so: $(SYSROOT_PATH)/lib/libdrm.so
	cp -rapL $< $@

$(SYSTEM_PATH)/lib/libdrm_%.so: $(SYSROOT_PATH)/lib/libdrm_%.so
	cp -rapL $(SYSROOT_PATH)/lib/$(shell basename $@) $@

$(CACHE_PATH)/libdrm-$(LIBDRM_VERSION).tar.xz:
	wget -nc https://dri.freedesktop.org/libdrm/libdrm-$(LIBDRM_VERSION).tar.xz -P $(shell dirname $@)

$(LIBDRM_PATH)/meson.build: $(CACHE_PATH)/libdrm-$(LIBDRM_VERSION).tar.xz
	mkdir -p $(shell dirname $@)
	tar -xmf $< -C $(shell dirname $@) --strip-components=1

$(LIBDRM_PATH)/build/build.ninja: $(MESON_TOOLCHAIN_FILE) $(LIBDRM_DEPENDENCIES) $(LIBDRM_PATH)/meson.build
	cd $(LIBDRM_PATH) && meson setup --cross-file $(MESON_TOOLCHAIN_FILE) $(shell dirname $@) --prefix=/ $(LIBDRM_OPTIONS)

$(SYSROOT_PATH)/lib/libdrm.so: $(LIBDRM_PATH)/build/build.ninja
	ninja -C $(shell dirname $<)
	DESTDIR=$(SYSROOT_PATH) ninja -C $(shell dirname $<) install
