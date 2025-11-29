-include ${.TOPDIR}/config.inc

TARGET_MACHINE 	?= $(shell uname -m)
TARGET_TRIPLET	:= ${TARGET_MACHINE}-linux-musl
HOST_TRIPLET    := $(shell gcc -dumpmachine)

GOOS			:= linux

ifeq (${TARGET_MACHINE}, x86_64)
GOARCH			:= amd64
else
$(error "unsupported go target machine ${TARGET_MACHINE}")
endif

BUILD_TYPE		?= debug

TOOLCHAIN_PATH	:= $(abspath ${.BUILDDIR}/toolchain.${TARGET_TRIPLET})
SYSROOT_PATH	:= ${TOOLCHAIN_PATH}/${TARGET_TRIPLET}/sysroot
RAMDISK_PATH    := $(abspath ${.BUILDDIR}/ramdisk.${TARGET_TRIPLET})

SOURCES_PATH	?= $(abspath ${.BUILDDIR}/sources)
IMAGES_PATH		?= $(abspath ${.BUILDDIR}/images.${TARGET_TRIPLET})

export PATH		:= ${TOOLCHAIN_PATH}/bin:${PATH}
