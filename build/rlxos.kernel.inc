KERNEL_SOURCE ?= ${.TOPDIR}/_external/linux

KERNEL_MAKE_ARGS := -C ${KERNEL_SOURCE} O=$(abspath .)
KERNEL_MAKE_ARGS += ARCH=${TARGET_MACHINE} CROSS_COMPILE=${TARGET_TRIPLET}-

KERNEL_CONFIG_PATH := $(abspath ${.SRCDIR}/${KERNEL_CONFIG})

all: ${IMAGES_PATH}/kernel.img

${IMAGES_PATH}/kernel.img: .build-done
	cp $(shell make ${KERNEL_MAKE_ARGS} -s image_name) ${IMAGES_PATH}/kernel.img

.configure-done: ${KERNEL_SOURCE}/Makefile ${KERNEL_CONFIG_PATH}
	${MAKE} ${KERNEL_MAKE_ARGS} defconfig
	KCONFIG_PATH=$(abspath .config) \
		${KERNEL_SOURCE}/scripts/kconfig/merge_config.sh -m .config \
			${KERNEL_CONFIG_PATH}
	${MAKE} ${KERNEL_MAKE_ARGS} olddefconfig
	touch $@

.build-done: .configure-done
	@mkdir -p ${IMAGES_PATH}
	${MAKE} ${KERNEL_MAKE_ARGS}
	${MAKE} ${KERNEL_MAKE_ARGS} INSTALL_MOD_PATH=${SYSROOT_PATH}/ INSTALL_MOD_STRIP=1 modules_install
	touch $@

clean:

install:

compile_db:

fetch_sources:
