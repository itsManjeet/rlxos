#!/bin/bash



FILE_SRC_FLDR="file-$FILE_VERSION"

RLXOS_DOWNLOAD "ftp://ftp.astron.com/pub/file/$FILE_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $FILE_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$FILE_SRC_FLDR

mkdir -p build && cd build
../configure --disable-bzlib \
    --disable-libseccomp \
    --disable-xzlib \
    --disable-zlib

make
cd ..

./configure --prefix=/usr \
    --host=$RLXOS_TGT \
    --build=$(./config.guess)

make FILE_COMPILE=$(pwd)/build/src/file
make DESTDIR=$RLX install
