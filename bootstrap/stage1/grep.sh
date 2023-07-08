#!/bin/bash



GREP_SRC_FLDR="grep-$GREP_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/grep/$GREP_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $GREP_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$GREP_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT

make
make DESTDIR=$RLX install