#!/bin/bash

BASEDIR="$(
    cd -- "$(dirname "$0")" >/dev/null 2>&1
    pwd -P
)"

. ${BASEDIR}/common.sh

#exec 3>&1 4>&2
#trap 'exec 2>&4 1>&3' 0 1 2 3
#exec 1> /logs/$(date '+%Y-%m-%d-%H').log 2>&1

echo "Version: ${VERSION}"

rm /var/lib/pkgupd/data/*

echo "Regenerating toolchain build"
for i in kernel-headers glibc binutils gcc binutils glibc ; do
    pkgupd co ${i}
    if [[ $? != 0 ]] ; then
        echo "failed to build toolchain ${i}"
        exit 1
    fi
done

pkgupd co pkgupd

echo "Generating package dependency tree"
DEPS="iana-etc
filesystem
attr
kernel-headers
glibc
tzdata
zlib
bzip2
file
readline
libgmp
libmpfr
libmpc
binutils
gcc
acl
libcap
pam
shadow
pam-config
ncurses
bash
grep
sed
psmisc
libtool
xz
gdbm
perl
openssl
zstd
pkg-config
kmod
gettext
gawk
m4
autoconf
automake
coreutils
diffutils
findutils
which
inetutils
expat
libffi
sqlite
python
py-setuptools
py-markupsafe
py-jinja2
lz4
ninja
meson
gperf
systemd
procps-ng
bc
util-linux
e2fsprogs
less
gzip
iptables
libelf
flex
bison
iproute2
kbd
texinfo
groff
libpipeline
man-db
vim
libuv
libunistring
libidn2
ca-certificates
curl
libarchive
cmake
libyaml-cpp
tar
dbus
sudo
core
linux initramfs libaio lvm2 efivar firmware
popt
efibootmgr
libpng
freetype
libburn
libisofs
libisoburn
dosfstools
 grub-legacy grub"
echo "Dependencies: ${DEPS}"

for i in ${DEPS} ; do
    echo "Compiling $(basename ${i})"
    DEBUG=1 CURL_DEBUG=1 pkgupd co ${i}
    if [[ ${?} -ne 0 ]] ; then
        echo "build failed ${i}"
        exit 1
    fi
done

export ROOTFS=/tmp/rlxos-rootfs
GenerateRootfs core
if [[ $? -ne 0 ]] ; then
  echo "rootfs build failed ${?}"
  exit 1
fi

GenerateRootfs binutils make automake autoconf meson ninja flex bison pkg-config kernel-headers
[[ $? -ne 0 ]] && exit 1
tar -caf /releases/rootfs-devel.tar.zstd --zstd -C ${ROOTFS} .

