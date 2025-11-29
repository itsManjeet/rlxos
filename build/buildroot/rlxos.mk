.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc

DISTDIR		 = ${.TOPDIR}/_external/buildroot

MAKE_ARGS	 = -C ${DISTDIR}
MAKE_ARGS	+= BR2_DEFCONFIG=${.SRCDIR}/${TARGET_MACHINE}_defconfig
MAKE_ARGS	+= BR2_DL_DIR=${SOURCES_PATH}
MAKE_ARGS	+= TOOLCHAIN_PATH="${TOOLCHAIN_PATH}"
MAKE_ARGS	+= O=${.OBJDIR}
MAKE_ARGS	+= V=1

all: .install-done

.install-done: .build-done
	@for i in lib include; do \
		rsync -a host/${TARGET_MACHINE}-buildroot-linux-musl/sysroot/$$i/ \
			${SYSROOT_PATH}/$$i/ || exit 1; \
	done
	@for i in cmd data config; do \
		rsync -a target/$$i/ ${SYSROOT_PATH}/$$i/ || exit 1; \
	done	
	@touch $@

.build-done: .config
	[ -L ${SYSROOT_PATH}/usr ] && true || ln -sf . ${SYSROOT_PATH}/usr
	${MAKE} ${MAKE_ARGS}
	@touch $@

.config: ${DISTDIR}/Makefile ${.SRCDIR}/${TARGET_MACHINE}_defconfig
	${MAKE} ${MAKE_ARGS} defconfig

clean:
	${MAKE} ${MAKE_ARGS} clean
	rm .config

menuconfig: ${DISTDIR}/Makefile
	${MAKE} ${MAKE_ARGS} menuconfig

install:
compile_db:
fetch-sources:
