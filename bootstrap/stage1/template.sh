#!/bin/bash



@BNAME@_SRC_FLDR="@SNAME@-$@BNAME@_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/@SNAME@/$@BNAME@_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $@BNAME@_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$@BNAME@_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install