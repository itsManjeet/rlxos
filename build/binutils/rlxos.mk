.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR := ${.TOPDIR}/_external/binutils

CONFIGURE_ARGS := 					\
	--prefix=${TOOLCHAIN_PATH}		\
	--target=${TARGET_TRIPLET}		\
	--with-sysroot=${SYSROOT_PATH}	\
	--with-gmp=${TOOLCHAIN_PATH}	\
	--with-mpfr=${TOOLCHAIN_PATH}	\
	--with-mpc=${TOOLCHAIN_PATH}	\
	--disable-nls					\
	--disable-multilib

PRE_BUILD_COMMANDS += 				\
	${MAKE} configure-host;

POST_BUILD_COMMANDS += 				\
	${MAKE} install;

include ${.TOPDIR}/build/rlxos.autotools.inc