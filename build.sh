#!/bin/bash

#
# Generate System toolchain and packages for rlxos
#

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

FILES=${BASEDIR}/files
REPODB=${BASEDIR}/recipes
PKGSDIR=${BASEDIR}/pkgs
SRCDIR=${BASEDIR}/src
CFLAGS="-march=x86-64 -O2 -pipe"
CXXFLAGS="-march=x86-64 -O2 -pipe"
MAKEFLAGS="-j$(nproc)"

if [[ -z "${NOCONTAINER}" ]]; then
    echo ":: Executing inside container ::"
    docker run \
        --env NOCONTAINER=1 \
        -v $(realpath ${0}):/build.sh \
        -v ${REPODB}:/var/cache/pkgupd/recipes \
        -v ${PKGSDIR}:/var/cache/pkgupd/pkgs \
        -v ${SRCDIR}:/var/cache/pkgupd/src \
        -v ${FILES}:/var/cache/pkgupd/files \
        -v ${BASEDIR}/pkgupd.yml:/etc/pkgupd.yml \
        -it itsmanjeet/rlxos-devel bash build.sh
    exit $?
fi

mkdir -p ${PKGDIR}

VERSION=${VERSION:-'TESTBUILD'}
SYS_TOOLCHAIN='kernel-headers glibc binutils gcc binutils glibc'
BUILDDIR=${BUILDDIR:-"${BASEDIR}/build"}
OUTPUT=${OUTPUT:-"${BUILDDIR}/rlxos-${VERSION}.rootfs"}
SYSROOT=${BUILDDIR}/sysroot
DATADIR=${SYSROOT}/var/lib/pkgupd/data

# Core system package
CORESYSTEM='iana-etc kernel-headers glibc tzdata zlib bzip2 xz zstd file readline m4 bc flex binutils libgmp
    libmpfr libmpc attr acl libcap pam pam-config shadow gcc pkg-config
    ncurses sed psmisc gettext bison grep bash libtool gdbm gperf expat
    inetutils less perl perl-xml-parser intltool autoconf automake kmod libelf
    libffi openssl python ninja meson coreutils diffutils gawk findutils
    groff gzip iptables iproute2 kbd libpipeline make patch tar texinfo vim py-markupsafe
    py-jinja2 lz4 systemd dbus man-db procps-ng util-linux e2fsprogs libunistring libidn2 ca-certificates curl libarchive libyaml-cpp libuv cmake pkgupd'

if [[ -e /.dockerenv ]]; then
    echo "=> Refreshing Recipes"
    pkgupd refresh ${PKGUPD_ARGS}
    if [[ $? != 0 ]]; then
        echo "Error! Failed to refresh"
        exit 1
    fi
fi

for sys in ${SYS_TOOLCHAIN}; do
    echo "=> Generating Toolchain package ${sys}"
    pkgupd co ${sys} --force
    if [[ $? != 0 ]]; then
        echo "Error! Failed to generate ${sys}"
        exit 1
    fi
done

for pkg in ${CORESYSTEM}; do
    echo "=> Compiling core package ${pkg}"
    pkgupd co ${pkg} --force
    if [[ $? != 0 ]]; then
        echo "Error! failed to build core package ${pkg}"
        exit 1
    fi
done

mkdir -p ${SYSROOT} ${DATADIR}

for pkg in ${CORESYSTEM}; do
    echo "=> Installing core system package ${pkg}"
    pkgupd in ${pkg} sys-db=${DATADIR} root-dir=${SYSROOT}
    if [[ $? != 0 ]]; then
        echo "Error! failed to install ${pkg}"
        exit 1
    fi
done

echo ":: Generating tar package ::"
tar --zstd -caf ${OUTPUT} -C ${SYSROOT} .
if [[ $? != 0 ]]; then
    echo "Error! failed to generate tar archive"
    exit 1
fi

rm -rf ${SYSROOT} ${DATADIR}
