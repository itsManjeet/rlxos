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
	--with-gmp=${TOOLCHAIN_PATH}				\
	--with-mpfr=${TOOLCHAIN_PATH}				\
	--with-mpc=${TOOLCHAIN_PATH}				\
	--with-newlib								\
	--enable-language=c							\
	--disable-nls								\
	--disable-shared							\
	--disable-multilib							\
	--disable-decimal-float 					\
	--disable-libgomp 							\
	--disable-libmudflap 						\
	--disable-libssp 							\
	--disable-libatomic 						\
	--disable-libquadmath 						\
	--disable-threads 							\

BUILD_ARGS = all-gcc all-target-libgcc

POST_BUILD_COMMANDS += 				\
	${MAKE} install-gcc install-target-libgcc;

include ${.TOPDIR}/build/rlxos.autotools.inc