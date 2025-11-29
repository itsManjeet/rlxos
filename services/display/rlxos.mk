.TOPDIR ?= ../..
include ${.TOPDIR}/build/rlxos.defaults.inc
include ${.TOPDIR}/build/rlxos.toolchain.inc

CGO_ENABLED			 = 1
CGO_CFLAGS			+= -I $(CURDIR)

SERVICE				 = display@.service display@tty1.service

PRE_TARGETS			 = xdg-shell-protocol.h wlr-layer-shell-unstable-v1-protocol.h
POST_TARGETS		 = $(addprefix ${SYSROOT_PATH}/config/services.d/,${SERVICE})

include ${.TOPDIR}/build/rlxos.go.inc

xdg-shell-protocol.h: ${.SRCDIR}/protocols/xdg-shell.xml
	wayland-scanner server-header $< $@

wlr-layer-shell-unstable-v1-protocol.h: ${.SRCDIR}/protocols/wlr-layer-shell-unstable-v1.xml
	wayland-scanner server-header $< $@

${SYSROOT_PATH}/config/services.d/%: ${.SRCDIR}/%
	@mkdir -p $(dir $@)
	cp $< $@

${SYSROOT_PATH}/config/services.d/display@tty1.service: ${SYSROOT_PATH}/config/services.d/display@.service
	ln -sv display@.service $@