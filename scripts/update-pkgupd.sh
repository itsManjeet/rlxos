#!/bin/bash

if [[ -d build/pkgupd/cache ]] ; then
    cmake -B build/pkgupd/cache -S core/pkgupd -DCMAKE_INSTALL_PREFIX=/usr
fi
cmake --build  build/pkgupd/cache -j$(nproc)
cmake --install  build/pkgupd/cache