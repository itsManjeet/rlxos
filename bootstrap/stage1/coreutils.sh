#!/bin/bash



COREUTILS_SRC_FLDR="coreutils-$COREUTILS_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/coreutils/$COREUTILS_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $COREUTILS_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$COREUTILS_SRC_FLDR


./configure --prefix=/usr   \
            --bindir=/usr/bin \
            --sbindir=/usr/bin \
            --libexecdir=/usr/lib \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess) \
            --enable-install-program=hostname \
            --enable-no-install-program=kill,uptime

make
make DESTDIR=$RLX install
