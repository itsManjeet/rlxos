.TOPDIR ?= ..
include ${.TOPDIR}/build/rlxos.defaults.inc

TARGETS		:= $(shell find ${.SRCDIR} -type f)
TARGETS		:= ${TARGETS:${.SRCDIR}/%=${SYSROOT_PATH}/data/%}

all: ${TARGETS}

${SYSROOT_PATH}/data/%: ${.SRCDIR}/%
	@mkdir -p $(dir $@)
	cp -a $< $@
