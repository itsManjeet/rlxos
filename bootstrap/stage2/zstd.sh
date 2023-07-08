#!/bin/bash



ZSTD_SRC_FLDR="zstd-$ZSTD_VERSION"

RLXOS_DOWNLOAD "https://github.com/facebook/zstd/releases/download/v$ZSTD_VERSION/$ZSTD_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $ZSTD_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$ZSTD_SRC_FLDR


make
make prefix=/usr install