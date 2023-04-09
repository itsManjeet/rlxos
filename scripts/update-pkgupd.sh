#!/bin/bash

rm build/pkgupd/cache -rf
cmake -B build/pkgupd/cache -S src/pkgupd -DCMAKE_INSTALL_PREFIX=/usr
cmake --build  build/pkgupd/cache -j$(nproc)
cmake --install  build/pkgupd/cache