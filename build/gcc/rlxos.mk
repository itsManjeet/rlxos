.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR := ${.TOPDIR}/_external/gcc

CONFIGURE_ARGS := 								\
	--prefix=${TOOLCHAIN_PATH}					\
	--target=${TARGET_TRIPLET}					\
	--build=${HOST_TRIPLET}						\
	--host=${HOST_TRIPLET}						\
	--libexecdir=${TOOLCHAIN_PATH}/lib 			\
	--with-sysroot=${SYSROOT_PATH}				\
	--with-local-prefix=/ 						\
	--with-native-system-header-dir="/include"	\
	--with-gmp=${TOOLCHAIN_PATH}				\
	--with-mpfr=${TOOLCHAIN_PATH}				\
	--with-mpc=${TOOLCHAIN_PATH}				\
	--enable-c99								\
	--enable-language=c,c++						\
	--disable-nls								\
	--disable-libmudflap 						\
	--disable-multilib 							\
	--disable-libmpx 							\
	--disable-libssp 							\
	--disable-libsanitizer

POST_BUILD_COMMANDS += 							\
	${MAKE} install;

include ${.TOPDIR}/build/rlxos.autotools.inc