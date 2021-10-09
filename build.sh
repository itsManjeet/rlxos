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

BUILDDIR=${BUILDDIR:-"/var/cache/pkgupd/build"}

[[ -t 1 ]] && INTERACTIVE='-i'
if [[ -z "${NOCONTAINER}" ]]; then
    echo ":: Initializing Container ::"
    docker run \
        --rm \
	--network host \
        -v "$(realpath ${0}):/build.sh" \
	-v "${BASEDIR}/tmp:/tmp" \
        -v "${REPODB}:/var/cache/pkgupd/recipes" \
        -v "${PKGSDIR}:/var/cache/pkgupd/pkgs" \
        -v "${SRCDIR}:/var/cache/pkgupd/src" \
        -v "${FILES}:/var/cache/pkgupd/files" \
        -v "${BASEDIR}/build:${BUILDDIR}" \
        -v "${BASEDIR}/pkgupd.yml:/etc/pkgupd.yml" \
        -v "${BASEDIR}/.profile:/profile" \
        ${INTERACTIVE} --privileged \
        -t itsmanjeet/rlxos-devel:2110 /usr/bin/env -i \
            HOME=/root \
            TERM=${TERM} \
            PS1='(rlxos chroot) \u:\w\$ ' \
            PATH='/usr/bin:/opt/bin' \
            NOCONTAINER=1 \
            /bin/bash /build.sh ${@}
    exit $?
fi

mkdir -p ${PKGSDIR}

RELEASE='continuous'

ARGS=()
while [[ $# -gt 0 ]]; do
    key="${1}"
    case ${key} in
    -r | --release)
        RELEASE="${2}"
        shift
        ;;
    --rebuild)
        REBUILD=1
        shift
        ;;

    --exec)
        EXECUTE="${2}"
        shift
        ;;
    *)
        echo "Error! invalid argument ${key}"
        exit 1
        ;;
    esac
    shift
done

SYS_TOOLCHAIN='kernel-headers glibc binutils gcc binutils glibc'
OUTPUT=${OUTPUT:-"${BUILDDIR}/rlxos-${RELEASE}"}
SYSROOT=${BUILDDIR}/sysroot
DATADIR=${SYSROOT}/var/lib/pkgupd/data

if [[ -n ${EXECUTE} ]]; then
    echo "Executing: ${EXECUTE}"
    ${EXECUTE}
    exit $?
fi

echo "=> Reinstalling pkgupd"
pkgupd in pkgupd --force --skip-depends
if [[ $? != 0 ]]; then
    echo "Error! Failed to reinstall pkgupd"
    exit 1
fi

if [[ ${REBUILD} -eq 1 ]]; then
    for sys in ${SYS_TOOLCHAIN}; do
        echo "=> Generating Toolchain package ${sys}"
        pkgupd co ${sys} --force
        if [[ $? != 0 ]]; then
            echo "Error! Failed to generate ${sys}"
            exit 1
        fi
    done
fi

[[ ${REBUILD} ]] && FORCE='--force'

PACKAGES=$(awk -F '=' '/packages/ {print $2}' /profile)
rm /var/lib/pkgupd/data/*
for pkg in $(pkgupd deptest ${PACKAGES} squashfs-tools mtools grub --force ) ;  do
    echo "=> Compiling ${pkg}"
    pkgupd co ${pkg} ${FORCE}
    if [[ $? != 0 ]]; then
        echo "Error! failed to compile package ${pkg}"
        /bin/bash
        exit 1
    fi
done

mkdir -p ${SYSROOT} ${DATADIR}

for pkg in ${PACKAGES}; do
    echo "=> Installing core system package ${pkg}"
    pkgupd in ${pkg} sys-db=${DATADIR} root-dir=${SYSROOT} --skip-triggers
    if [[ $? != 0 ]]; then
        echo "Error! failed to install ${pkg}"
        exit 1
    fi
done

echo "inside root"
chroot ${SYSROOT} bash <<"EOT"
pwconv
grpconv
echo -e "rlxos\nrlxos" | passwd

pkgupd trigger
EOT

echo ":: Generating tar package ::"
tar --zstd -caf ${OUTPUT}.rootfs -C ${SYSROOT} .
if [[ $? != 0 ]]; then
    echo "Error! failed to generate tar archive"
    exit 1
fi

rm ${OUTPUT}.sys

echo ":: Generating System Image ::"
mksquashfs ${SYSROOT}/* ${OUTPUT}.sys
if [[ $? != 0 ]]; then
    echo "Error! failed to generate system Image"
    exit 1
fi

echo ":: Generating ISO ::"
_iso_dir='/tmp/rlxos-iso'
mkdir -p ${_iso_dir}/boot/grub
echo "default='rlxos installer'
timeout=5
menuentry 'rlxos installer' {
    linux /boot/vmlinuz iso=1 root=LABEL=RLXOS system=${VERSION}
    initrd /boot/initrd
}" >${_iso_dir}/boot/grub/grub.cfg

cp /boot/vmlinuz ${_iso_dir}/boot/vmlinuz

mkinitramfs -k=$(ls /lib/modules) -o=${_iso_dir}/boot/initrd
cp ${OUTPUT}.sys ${_iso_dir}/rootfs.img

grub-mkrescue -volid RLXOS ${_iso_dir} -o ${OUTPUT}.iso

rm -rf ${SYSROOT} ${DATADIR}
