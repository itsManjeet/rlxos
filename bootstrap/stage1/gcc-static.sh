#!/bin/bash

. .config.sh
. ver.sh

set -e

GCC_SRC_FLDR="gcc-$GCC_VERSION"
MPFR_SRC_FLDR="mpfr-$MPFR_VERSION"
MPC_SRC_FLDR="mpc-$MPC_VERSION"
GMP_SRC_FLDR="gmp-$GMP_VERSION"

RLXOS_DOWNLOAD http://ftp.gnu.org/gnu/gcc/$GCC_SRC_FLDR/$GCC_SRC_FLDR.tar.xz
RLXOS_DOWNLOAD http://www.mpfr.org/$MPFR_SRC_FLDR/$MPFR_SRC_FLDR.tar.xz
RLXOS_DOWNLOAD https://ftp.gnu.org/gnu/mpc/$MPC_SRC_FLDR.tar.gz
RLXOS_DOWNLOAD http://ftp.gnu.org/gnu/gmp/$GMP_SRC_FLDR.tar.xz

RLXOS_EXTRACT $GCC_SRC_FLDR.tar.xz
# RLXOS_EXTRACT $GMP_SRC_FLDR.tar.xz
# RLXOS_EXTRACT $MPFR_SRC_FLDR.tar.xz
# RLXOS_EXTRACT $MPC_SRC_FLDR.tar.gz

tar -xaf $RLXOS_SRC_DIR/$GMP_SRC_FLDR.tar.xz -C $RLXOS_BUILD_DIR/
tar -xaf $RLXOS_SRC_DIR/$MPFR_SRC_FLDR.tar.xz -C $RLXOS_BUILD_DIR/
tar -xaf $RLXOS_SRC_DIR/$MPC_SRC_FLDR.tar.gz -C $RLXOS_BUILD_DIR/

cd $RLXOS_BUILD_DIR/$GCC_SRC_FLDR

mv -v ../$MPFR_SRC_FLDR mpfr
mv -v ../$GMP_SRC_FLDR gmp
mv -v ../$MPC_SRC_FLDR mpc

# usr lib instead of lib64
case "$RLXOS_ARCH" in
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64
        ;;
esac

mkdir -pv build && cd build


../configure                                       \
    --target=$RLXOS_TGT                              \
    --prefix=$RLXOS/tools                            \
    --with-glibc-version=2.34                      \
    --with-sysroot=$RLX                            \
    --with-newlib                                  \
    --without-headers                              \
    --enable-initfini-array                        \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++

make
make install

cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($RLXOS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
