.TOPDIR ?= ../../..
include ${.TOPDIR}/build/rlxos.defaults.inc

KERNEL_CONFIG := GENERIC

include ${.TOPDIR}/build/rlxos.kernel.inc