#!/bin/bash



M4_SRC_FLDR="m4-$M4_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/m4/$M4_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $M4_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$M4_SRC_FLDR


sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h

./configure --prefix=/usr   \
            --host=$RLXOS_TGT \
            --build=$(build-aux/config.guess)

make
make DESTDIR=$RLX install