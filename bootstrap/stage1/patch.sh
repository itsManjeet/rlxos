#!/bin/bash



PATCH_SRC_FLDR="patch-$PATCH_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/patch/$PATCH_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $PATCH_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$PATCH_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install