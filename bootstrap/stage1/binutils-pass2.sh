#!/bin/bash

. .config.sh
. ver.sh

set -e

BINUTILS_SRC_FLDR="binutils-${BINUTILS_VER}"
RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/binutils/$BINUTILS_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $BINUTILS_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$BINUTILS_SRC_FLDR

mkdir -p build && cd build

../configure                   \
    --prefix=/usr              \
    --build=$(../config.guess) \
    --host=$RLXOS_TGT            \
    --disable-nls              \
    --enable-shared            \
    --disable-werror           \
    --enable-64-bit-bfd

make

make DESTDIR=$RLX install
install -vm755 libctf/.libs/libctf.so.0.0.0 ${RLX}/usr/lib