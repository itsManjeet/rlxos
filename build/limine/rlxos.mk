.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR = ${.TOPDIR}/_external/limine

export CC = gcc

CONFIGURE_ARGS := \
	--prefix=${TOOLCHAIN_PATH} \
	--enable-all \
	CC=gcc

POST_BUILD_COMMANDS += 			\
	${MAKE} install;

include ${.TOPDIR}/build/rlxos.autotools.inc

${DISTDIR}/configure: ${DISTDIR}/bootstrap
	cd ${DISTDIR}; ./bootstrap