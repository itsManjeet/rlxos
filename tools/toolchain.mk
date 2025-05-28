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

define MESON_TOOLCHAIN_FILE =
[binaries]
c = '$(TOOLCHAIN_TARGET_TRIPLE)-gcc'
cpp = '$(TOOLCHAIN_TARGET_TRIPLE)-g++'
ar = '$(TOOLCHAIN_TARGET_TRIPLE)-ar'
strip = '$(TOOLCHAIN_TARGET_TRIPLE)-strip'

[host_machine]
system = 'linux'
cpu_family = '$(shell uname -m)'
cpu = '$(shell uname -m)'
endian = 'little'
endef
export MESON_TOOLCHAIN_FILE

gen-toolchain-file: $(DEVICE_CACHE_PATH)/$(TOOLCHAIN_TARGET_TRIPLE).meson.txt

$(DEVICE_CACHE_PATH)/$(TOOLCHAIN_TARGET_TRIPLE).meson.txt: $(TOOLCHAIN_PATH)/bin/$(TOOLCHAIN_TARGET_TRIPLE)-gcc
	echo "$$MESON_TOOLCHAIN_FILE" > $@