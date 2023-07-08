#!/bin/bash



SED_SRC_FLDR="sed-$SED_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/sed/$SED_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $SED_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$SED_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT

make
make DESTDIR=$RLX install