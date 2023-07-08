#!/bin/bash

set -e

. .config.sh
. ver.sh

KRNL_SRC_FLDR="linux-$KERNEL_VERSION"

RLXOS_DOWNLOAD "https://www.kernel.org/pub/linux/kernel/v5.x/$KRNL_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $KRNL_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$KRNL_SRC_FLDR
make mrproper

make ARCH=${RLXOS_ARCH} headers_check


make ARCH=${RLXOS_ARCH} headers

find usr/include -name '.*' -delete
rm usr/include/Makefile

cp -rv usr/include $RLXOS/usr
