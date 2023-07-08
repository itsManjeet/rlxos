#!/bin/bash



GAWK_SRC_FLDR="gawk-$GAWK_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/gawk/$GAWK_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $GAWK_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GAWK_SRC_FLDR

sed -i 's/extras//' Makefile.in

./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --libexecdir=/usr/lib \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install