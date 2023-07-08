#!/bin/bash



WGET_SRC_FLDR="wget-$WGET_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/wget/$WGET_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $WGET_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$WGET_SRC_FLDR


./configure --prefix=/usr   \
            --sysconfdir=/etc \
            --with-ssl=openssl

make
make install