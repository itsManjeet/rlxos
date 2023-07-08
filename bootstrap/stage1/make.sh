#!/bin/bash



MAKE_SRC_FLDR="make-$MAKE_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/make/$MAKE_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $MAKE_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$MAKE_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess) \
            --without-guile

make
make DESTDIR=$RLX install