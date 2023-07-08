#!/bin/bash



CURL_SRC_FLDR="curl-$CURL_VERSION"

RLXOS_DOWNLOAD "https://curl.haxx.se/download/$CURL_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $CURL_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/$CURL_SRC_FLDR


./configure --prefix=/usr --with-openssl --enable-threaded-resolver

make
make install
