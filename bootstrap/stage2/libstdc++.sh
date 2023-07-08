#!/bin/bash

. /.config.sh
. /ver.sh

set -e

GCC_SRC_FLDR="gcc-$GCC_VERSION"


RLXOS_DOWNLOAD http://ftp.gnu.org/gnu/gcc/$GCC_SRC_FLDR/$GCC_SRC_FLDR.tar.xz

RLXOS_EXTRACT $GCC_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GCC_SRC_FLDR


ln -s gthr-posix.h libgcc/gthr-default.h

mkdir -pv build && cd build

../libstdc++-v3/configure            \
    CXXFLAGS="-g -O2 -D_GNU_SOURCE"  \
    --prefix=/usr                    \
    --disable-multilib               \
    --disable-nls                    \
    --host=${RLXOS_ARCH}-rlx-linux-gnu \
    --disable-libstdcxx-pch

make
make install
