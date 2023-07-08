#!/bin/bash



XZ_SRC_FLDR="xz-$XZ_VERSION"

RLXOS_DOWNLOAD "https://tukaani.org/xz/$XZ_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $XZ_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$XZ_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess) \
            --disable-static \
            --docdir=/usr/doc/xz

make
make DESTDIR=$RLX install
