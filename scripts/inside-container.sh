#!/bin/bash -e
STORAGE_DIR=${STORAGE_DIR:-"${PWD}/storage"}

[[ ! -d "${STORAGE_DIR}" ]] && mkdir -p "${STORAGE_DIR}"

podman run                                                            \
    --privileged                                                      \
    -v "${PWD}":/rlxos                                                \
    -v "${PWD}"/pkgupd.yml:/etc/pkgupd.yml                            \
    -v "${STORAGE_DIR}":/storage                                      \
    -w /rlxos                                                         \
    -it itsmanjeet/devel-docker:2200-3                                \
    bash