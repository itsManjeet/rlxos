.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR := ${.TOPDIR}/_external/mpfr

CONFIGURE_ARGS := 					\
	--prefix=${TOOLCHAIN_PATH}		\
	--with-gmp=${TOOLCHAIN_PATH}

POST_BUILD_COMMANDS += 				\
	${MAKE} install;

include ${.TOPDIR}/build/rlxos.autotools.inc