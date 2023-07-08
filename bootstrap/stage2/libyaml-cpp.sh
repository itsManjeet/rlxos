#!/bin/bash



LIBYAML_CPP_SRC_FLDR="yaml-cpp-$LIBYAML_CPP_VERSION"

RLXOS_DOWNLOAD "https://github.com/jbeder/yaml-cpp/archive/refs/tags/$LIBYAML_CPP_SRC_FLDR.tar.gz"

RLXOS_EXTRACT $LIBYAML_CPP_SRC_FLDR.tar.gz

cd $RLXOS_BUILD_DIR/yaml-cpp-$LIBYAML_CPP_SRC_FLDR

cmake -B build -DBUILD_SHARED_LIBS=ON -DYAML_BUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr
cmake --build build
cmake --install build