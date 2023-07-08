#!/bin/bash



FINDUTILS_SRC_FLDR="findutils-$FINDUTILS_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/findutils/$FINDUTILS_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $FINDUTILS_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$FINDUTILS_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install