.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR = ${.TOPDIR}/_external/musl

CONFIGURE_ARGS := \
	--prefix=/ \
	--host=${TARGET_TRIPLET} \
	--build=${HOST_TRIPLET} \
	--target=${TARGET_TRIPLET}

POST_BUILD_COMMANDS += \
	${MAKE} install DESTDIR=${SYSROOT_PATH}

include ${.TOPDIR}/build/rlxos.autotools.inc
