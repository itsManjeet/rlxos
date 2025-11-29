export CC			:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-gcc
export CXX			:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-g++
export AS			:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-as
export LD			:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-ld
export AR			:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-ar
export STRIP		:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-strip
export RANLIB		:= ${TOOLCHAIN_PATH}/bin/${TARGET_TRIPLET}-ranlib

export PKG_CONFIG_SYSROOT_DIR	:= ${SYSROOT_PATH}
export PKG_CONFIG_LIBDIR		:= ${SYSROOT_PATH}/lib/pkgconfig

export GO			:= go