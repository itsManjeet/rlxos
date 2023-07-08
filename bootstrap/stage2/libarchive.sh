#!/bin/bash



LIBARCHIVE_SRC_FLDR="libarchive-$LIBARCHIVE_VERSION"

RLXOS_DOWNLOAD "https://github.com/libarchive/libarchive/releases/download/v${LIBARCHIVE_VERSION}/$LIBARCHIVE_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $LIBARCHIVE_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$LIBARCHIVE_SRC_FLDR


./configure --prefix=/usr

make
make install