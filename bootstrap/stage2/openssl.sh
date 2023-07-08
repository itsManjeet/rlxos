#!/bin/bash



OPENSSL_SRC_FLDR="openssl-$OPENSSL_VERSION"

RLXOS_DOWNLOAD "https://www.openssl.org/source/$OPENSSL_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $OPENSSL_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$OPENSSL_SRC_FLDR


./config --prefix=/usr \
            --libdir=/usr/lib \
            --openssldir=/etc/ssl \
            shared

make

make install