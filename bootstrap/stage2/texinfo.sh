#!/bin/bash



TEXINFO_SRC_FLDR="texinfo-$TEXINFO_VERSION"

RLXOS_DOWNLOAD "http://ftp.gnu.org/gnu/texinfo/$TEXINFO_SRC_FLDR.tar.xz"

RLXOS_EXTRACT $TEXINFO_SRC_FLDR.tar.xz

cd $RLXOS_BUILD_DIR/$TEXINFO_SRC_FLDR

# glibc-2.34
sed -e 's/__attribute_nonnull__/__nonnull/' \
    -i gnulib/lib/malloc/dynarray-skeleton.c

./configure --prefix=/usr

make
make install
