.TOPDIR ?= ..
include ${.TOPDIR}/build/rlxos.defaults.inc

TARGETS		:= $(shell find ${.SRCDIR} -type f)
TARGETS		:= ${TARGETS:${.SRCDIR}/%=${SYSROOT_PATH}/config/%}

all: ${TARGETS}

${SYSROOT_PATH}/config/%: ${.SRCDIR}/%
	@mkdir -p $(dir $@)
	cp -a $< $@
