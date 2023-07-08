#!/bin/bash



NCURSES_SRC_FLDR="ncurses-$NCURSES_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/ncurses/$NCURSES_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $NCURSES_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$NCURSES_SRC_FLDR

# to use gawk
sed -i s/mawk// configure

mkdir build
pushd build
  ../configure
  make -C include
  make -C progs tic
popd


./configure --prefix=/usr                \
            --host=$RLXOS_TGT              \
            --build=$(./config.guess)    \
            --mandir=/usr/share/man      \
            --with-manpage-format=normal \
            --with-shared                \
            --without-debug              \
            --without-ada                \
            --without-normal             \
            --enable-widec

make
make DESTDIR=$RLX TIC_PATH=$(pwd)/build/progs/tic install
echo "INPUT(-lncursesw)" > $RLXOS/usr/lib/libncurses.so
