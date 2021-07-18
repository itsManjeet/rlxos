#!/bin/sh

# Generate PKGUPD configuration file

set -u

BASEDIR="$(dirname $( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P ))"

CARCH=${CARCH:-x86_64}
RLXTGT=${CARCH}-rlxos-linux-gnu
RLXTGT32=i686-rlxos-linux-gnu
RLXOS=${BASEDIR}/build/rlxos.${RLXTGT}
TOOLS=${RLXOS}/tools

[[ ! -d ${TOOLS} ]] && mkdir -p ${TOOLS}

echo "
dir:
    recipes: ${BASEDIR}/recipes
    roots: ${RLXOS}
    pkgs: ${BASEDIR}/build/pkgs
    src: ${BASEDIR}/build/src
    data: ${RLXOS}/var/lib/pkgupd/data
    
default:
    repositories:
        - toolchain

environ:
    - RLXTGT=${RLXTGT}
    - RLXTGT32=${RLXTGT32}
    - RLXOS=${RLXOS}
    - TOOLS=${TOOLS}
    - PATH=${TOOLS}/bin:/usr/bin:/opt/bin
    - DESTDIR=\"\"
    - FILES=${BASEDIR}/files
" > ${BASEDIR}/pkgupd.yml

if [[ ! -L /tools ]] || [[ $(realpath /tools) != ${TOOLS} ]] ; then
    sudo ln -srv ${TOOLS} /tools
fi