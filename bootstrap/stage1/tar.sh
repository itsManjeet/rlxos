#!/bin/bash



TAR_SRC_FLDR="tar-$TAR_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/tar/$TAR_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $TAR_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$TAR_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install