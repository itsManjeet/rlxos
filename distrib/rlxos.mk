.TOPDIR ?= ..
include ${.TOPDIR}/build/rlxos.defaults.inc

SUBDIR = ${GOARCH}

include ${.TOPDIR}/build/rlxos.subdir.inc