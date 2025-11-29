.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR := ${.TOPDIR}/_external/linux

KERNEL_BUILD_ARGS := -C ${DISTDIR} ARCH=${TARGET_MACHINE} O=$(abspath .)

all: .build-done

clean:
install:
compile_db:

.build-done: ${DISTDIR}/Makefile
	${MAKE} ${KERNEL_BUILD_ARGS} mrproper
	${MAKE} ${KERNEL_BUILD_ARGS} headers
	${MAKE} ${KERNEL_BUILD_ARGS} headers_install INSTALL_HDR_PATH=${SYSROOT_PATH}
	touch $@
