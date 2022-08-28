#!/bin/bash

ARGS=()
OS_ID='rlxos GNU/Linux'
VERSION='testing'
LABEL='RLXOS'

while [[ $# -gt 0 ]] ; do
    case $1 in
        --grub-config)
            GRUB_FILE="$2"
            shift
        ;;

        --id)
            OS_ID="$2"
            shift
        ;;

        --label)
            LABEL="${2}"
            shift
        ;;

        --output)
            OUTPUT="${2}"
            shift
        ;;

        --kernel-version)
            KERNEL_VERSION="$2"
            shift
        ;;

        --system-image)
            SYSTEM_IMAGE="$2"
            shift
        ;;

        --overlay)
            OVERLAY_IMAGE="$2"
            shift
        ;;

        --version)
            VERSION="$2"
            shift
        ;;

        -*|--*)
            echo "Error! invalid option ${2}"
            exit 1
        ;;

        *)
            ARGS+=("$1")
        ;;
    esac
    shift
done

[[ -z ${SYSTEM_IMAGE} ]] && {
    echo "no system image specified"
    exit 1
}

[[ -z ${OVERLAY_IMAGE} ]] && {
    echo "no overlay image specified"
    exit 1
}

[[ -z ${OUTPUT} ]] && {
    echo "no output specified"
    exit 1
}

[[ -z ${KERNEL_VERSION} ]] && {
    echo "no kernel version specified"
    exit 1
}

REAL_KERNEL_VERSION="$(pkgupd info linux-${KERNEL_VERSION} info.value=version)-rlxos"
GRUB_CONFIG="
default=${OS_ID} [${VERSION}] Installer
timeout=5

insmod all_video
menuentry '${OS_ID} [${VERSION}] Installer' {
    linux /boot/vmlinuz-${REAL_KERNEL_VERSION} ro quiet fastboot loglevel=3 iso=1 root=LABEL=${LABEL} system=${VERSION}
    initrd /boot/initrd-${REAL_KERNEL_VERSION}
}"

if [[ -n ${GRUB_FILE} ]] ; then
    if [[ ! -e ${GRUB_FILE} ]] ; then
        echo "Error! ${GRUB_FILE} not exists"
        exit 1
    fi
    echo "=> using ${GRUB_FILE} grub file"
    GRUB_CONFIG=$(cat ${GRUB_FILE})
fi

ISODIR=$(mktemp -d /tmp/iso.XXXXXXXXXX)

function cleanup() {
    echo "=> cleaning cache"
    rm -r ${ISODIR}
}

echo "=> generating iso dir"
mkdir -p ${ISODIR}/boot/grub/

echo "=> configuring grub"
echo "${GRUB_CONFIG}" > ${ISODIR}/boot/grub/grub.cfg

echo "=> installing linux kernel ${KERNEL_VERSION}"
pkgupd install linux-${KERNEL_VERSION} dir.roots=${ISODIR} installer.depends=false force=true || {
    echo "Error! failed to install linux kernel"
    cleanup
    exit 1
}

echo "=> generating initramfs"
mkinitramfs -k=${REAL_KERNEL_VERSION} -o=${ISODIR}/boot/initrd-${REAL_KERNEL_VERSION} -u -m=${ISODIR}/boot/modules/linux-${REAL_KERNEL_VERSION} || {
    echo "Error! failed to generate initramfs image"
    cleanup
    exit 1
}

echo "=> installing system image"
cp ${SYSTEM_IMAGE} ${ISODIR}/rootfs.img || {
    echo "Error! failed to install system image"
    cleanup
    exit 1
}

echo "=> installing overlay image"
cp ${OVERLAY_IMAGE} ${ISODIR}/iso.img || {
    echo "Error! failed to install overlay image"
    cleanup
    exit 1
}

echo "${VERSION}" > ${ISODIR}/version

echo "=> generating iso file ${OUTPUT}"
grub-mkrescue -volid ${LABEL} ${ISODIR} -o ${OUTPUT} || {
    echo "Error! failed to generate iso file"
    cleanup
    exit 1
}

(cd $(dirname ${OUTPUT}); md5sum $(basename ${OUTPUT}) > $(basename ${OUTPUT}).md5 )
cleanup

echo ":: generating ISO success ::"