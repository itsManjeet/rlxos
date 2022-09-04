#!/bin/bash -e

docker run  \
    --privileged \
    -v ${PWD}:/rlxos \
    -v ${PWD}/pkgupd.testing.yml:/etc/pkgupd.yml \
    -v /storage/testing/2200/pkgs:/var/cache/pkgupd/pkgs/ \
    -v ${PWD}/scripts:/scripts \
    -v ${PWD}/recipes:/var/cache/pkgupd/recipes \
    -w /rlxos \
    -it itsmanjeet/rlxos-devel:2200-2 \
    bash