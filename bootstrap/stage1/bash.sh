#!/bin/bash



BASH_SRC_FLDR="bash-$BASH_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/bash/$BASH_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $BASH_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$BASH_SRC_FLDR


./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess) \
            --without-bash-malloc

make
make DESTDIR=$RLX install

ln -sv bash ${RLX}/bin/sh