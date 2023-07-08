#!/bin/bash



PYTHON_SRC_FLDR="Python-$PYTHON_VERSION"

RLXOS_DOWNLOAD "https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $PYTHON_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$PYTHON_SRC_FLDR


./configure --prefix=/usr \
            --enable-shared \
            --without-ensurepip

make
make install