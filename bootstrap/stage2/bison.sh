#!/bin/bash



BISON_SRC_FLDR="bison-$BISON_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/bison/$BISON_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $BISON_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$BISON_SRC_FLDR


./configure --prefix=/usr   \
            --docdir=/usr/doc/bison

make
make install