#!/bin/bash



CMAKE_SRC_FLDR="cmake-$CMAKE_VERSION"

RLXOS_DOWNLOAD "https://github.com/Kitware/CMake/archive/refs/tags/v$CMAKE_VERSION.tar.gz"

RLXOS_EXTRACT v${CMAKE_VERSION}.tar.gz

cd $RLXOS_BUILD_DIR/CMake-${CMAKE_VERSION}

sed -i "/lib64/s/64//" Modules/GNUInstallDirs.cmake
./configure --prefix=/usr \
    --mandir=/share/man \
    --no-system-jsoncpp \
    --no-system-librhash \
    --docdir=/share/doc/cmake

make
make install