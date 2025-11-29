.TOPDIR ?= ..
include ${.TOPDIR}/build/rlxos.defaults.inc

SERVICE = debugd@.service debugd@ttyS0.service

SERVICE_TARGET = $(addprefix ${SYSROOT_PATH}/config/services.d/,${SERVICE})

all: ${SERVICE_TARGET}

${SYSROOT_PATH}/config/services.d/%: ${.SRCDIR}/%
	@mkdir -p $(dir $@)
	cp $< $@

${SYSROOT_PATH}/config/services.d/debugd@ttyS0.service: ${SYSROOT_PATH}/config/services.d/debugd@.service
	ln -sv debugd@.service $@

clean:
	rm -f ${SERVICE_TARGET}

compile_db:

fetch-sources:

#include ${.TOPDIR}/build/rlxos.go.inc