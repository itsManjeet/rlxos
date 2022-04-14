#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

export PKGUPD_NO_PROGRESS=1

echo "::updating system ::"
pkgupd update --no-ask

echo ":: updating pkgupd"
pkgupd in pkgupd --force --no-depends

$@