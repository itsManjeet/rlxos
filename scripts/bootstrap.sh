#!/bin/bash

for b in kernel-headers glibc binutils gcc glibc binutils gcc ; do
    echo "=> bootstrapping ${b}"
    pkgupd build build.repository=core /rlxos/core/${b}/${b}.yml || {
        echo "ERROR: failed to build ${b}"
        exit 1
    }
done