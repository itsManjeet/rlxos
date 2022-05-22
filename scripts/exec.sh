#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

echo "installing pkgupd"
DEBUG=1 pkgupd in pkgupd --force --no-depends

export PKGUPD_NO_PROGRESS=1
$@