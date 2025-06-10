export PATH := $(TOOLCHAIN_PATH)/bin:$(PATH)

export CC		:= $(TOOLCHAIN_TARGET_TRIPLE)-gcc
export CXX 		:= $(TOOLCHAIN_TARGET_TRIPLE)-ar
export AR 		:= $(TOOLCHAIN_TARGET_TRIPLE)-ar
export AS  		:= $(TOOLCHAIN_TARGET_TRIPLE)-as
export LD  		:= $(TOOLCHAIN_TARGET_TRIPLE)-ld
export RANLIB 	:= $(TOOLCHAIN_TARGET_TRIPLE)-ranlib
export STRIP 	:= $(TOOLCHAIN_TARGET_TRIPLE)-strip

export CFLAGS	+= -fPIC -static-libgcc
export CXXFLAGS	+= -fPIC -static-libgcc -static-libstdc++

export PKG_CONFIG_PATH += $(SYSROOT_PATH)/lib/pkgconfig:$(SYSROOT_PATH)/share/pkgconfig

define MESON_TOOLCHAIN_FILE_TEMPLATE =
[binaries]
c = '$(TOOLCHAIN_TARGET_TRIPLE)-gcc'
cpp = '$(TOOLCHAIN_TARGET_TRIPLE)-g++'
ar = '$(TOOLCHAIN_TARGET_TRIPLE)-ar'
strip = '$(TOOLCHAIN_TARGET_TRIPLE)-strip'
pkgconfig = 'pkg-config'

[host_machine]
system = 'linux'
cpu_family = '$(shell uname -m)'
cpu = '$(shell uname -m)'
endian = 'little'
sys_root = '$(SYSROOT_PATH)'
pkg_config_libdir = '$(SYSROOT_PATH)/lib/pkgconfig'
endef
export MESON_TOOLCHAIN_FILE_TEMPLATE

MESON_TOOLCHAIN_FILE = $(DEVICE_CACHE_PATH)/$(TOOLCHAIN_TARGET_TRIPLE).meson.txt

$(MESON_TOOLCHAIN_FILE): $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc
	echo "$$MESON_TOOLCHAIN_FILE_TEMPLATE" > $@