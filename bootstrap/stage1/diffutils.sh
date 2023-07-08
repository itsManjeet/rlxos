#!/bin/bash



DIFFUTILS_SRC_FLDR="diffutils-$DIFFUTILS_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/diffutils/$DIFFUTILS_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $DIFFUTILS_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$DIFFUTILS_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT

make
make DESTDIR=$RLX install