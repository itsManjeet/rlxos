#!/bin/bash

. .config.sh
. ver.sh

set -e

BINUTILS_SRC_FLDR="binutils-${BINUTILS_VER}"
RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/binutils/$BINUTILS_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $BINUTILS_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$BINUTILS_SRC_FLDR

mkdir -p build && cd build

../configure    \
    --prefix=$RLXOS/tools     \
    --with-sysroot=$RLX     \
    --target=$RLXOS_TGT       \
    --disable-nls           \
    --disable-werror

make

make install