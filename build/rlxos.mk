.TOPDIR ?= ..

include ${.TOPDIR}/build/rlxos.defaults.inc

SUBDIR  = compile_db

SUBDIR += gmp mpfr mpc
SUBDIR += kernel-headers binutils gcc-static
SUBDIR += musl
SUBDIR += gcc go

SUBDIR += buildroot

include ${.TOPDIR}/build/rlxos.subdir.inc
