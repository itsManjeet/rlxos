#!/bin/bash



GZIP_SRC_FLDR="gzip-$GZIP_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/gzip/$GZIP_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $GZIP_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GZIP_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install

#mv -v $RLXOS/usr/bin/gzip $RLXOS/bin
