.TOPDIR ?= ..
include ${.TOPDIR}/build/rlxos.defaults.inc

SUBDIR	 = busybox
SUBDIR	+= init lipi

include ${.TOPDIR}/build/rlxos.subdir.inc