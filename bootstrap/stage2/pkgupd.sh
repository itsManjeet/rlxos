#!/bin/bash



PKGUPD_SRC_FLDR="pkgupd-$PKGUPD_VERSION"

RLXOS_DOWNLOAD "https://github.com/itsManjeet/pkgupd/archive/refs/heads/${PKGUPD_VERSION}.tar.gz" ${PKGUPD_SRC_FLDR}.tar.gz

RLXOS_EXTRACT $PKGUPD_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$PKGUPD_SRC_FLDR

cmake -B build -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
cmake --install build