#!/bin/bash

. .config.sh
. ver.sh

set -e

GCC_SRC_FLDR="gcc-$GCC_VERSION"


RLXOS_DOWNLOAD http://ftp.gnu.org/gnu/gcc/$GCC_SRC_FLDR/$GCC_SRC_FLDR.tar.xz

RLXOS_EXTRACT $GCC_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GCC_SRC_FLDR


mkdir -pv build && cd build


../libstdc++-v3/configure           \
    --host=$RLXOS_TGT                 \
    --build=$(../config.guess)      \
    --prefix=/usr                   \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$RLXOS_TGT/include/c++/${GCC_VERSION}

make
make DESTDIR=$RLX install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($RLXOS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h