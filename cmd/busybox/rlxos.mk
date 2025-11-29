.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR  = ${.TOPDIR}/_external/busybox

BUSYBOX_MAKE_ARGS	 = -C ${DISTDIR} O=${.OBJDIR}
BUSYBOX_MAKE_ARGS	+= ARCH=${TARGET_MACHINE} CROSS_COMPILE=${TARGET_TRIPLET}-

MERGE_CONFIG_SH		 = ${.TOPDIR}/_external/linux/scripts/kconfig/merge_config.sh

all: ${SYSROOT_PATH}/cmd/busybox

${SYSROOT_PATH}/cmd/busybox: ${.OBJDIR}/busybox
	install -D -m 755 $< $@

${.OBJDIR}/busybox: ${.OBJDIR}/.config
	${MAKE} ${BUSYBOX_MAKE_ARGS} busybox

${.OBJDIR}/.config: ${DISTDIR}/Makefile ${.SRCDIR}/${TARGET_MACHINE}_defconfig
	${MAKE} ${BUSYBOX_MAKE_ARGS} defconfig
	KCONFIG_PATH=$@ \
		${MERGE_CONFIG_SH} -m $@ ${.SRCDIR}/${TARGET_MACHINE}_defconfig
	${MAKE} ${BUSYBOX_MAKE_ARGS} oldconfig

clean:
	${MAKE} ${BUSYBOX_MAKE_ARGS} clean
	rm -f ${.OBJDIR}/.config

install: ${.OBJDIR}/busybox
	install -D -m 755 $< ${DESTDIR}/cmd/busybox

compile_db:

fetch_sources:
