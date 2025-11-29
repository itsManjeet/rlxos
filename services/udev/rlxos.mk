.TOPDIR ?= ..
include ${.TOPDIR}/build/rlxos.defaults.inc

SERVICE = udev.service udev-trigger.service

SERVICE_TARGET = $(addprefix ${SYSROOT_PATH}/config/services.d/,${SERVICE})

all: ${SERVICE_TARGET}

${SYSROOT_PATH}/config/services.d/%: ${.SRCDIR}/%
	@mkdir -p $(dir $@)
	cp $< $@

clean:
	rm -f ${SERVICE_TARGET}

compile_db:

fetch-sources:

#include ${.TOPDIR}/build/rlxos.go.inc