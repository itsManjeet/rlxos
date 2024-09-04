#! /bin/bash

EFI_GUID='c12a7328-f81f-11d2-ba4b-00a0c93ec93b'
[[ -d /sys/firmware/efi ]] && IS_EFI=1

if [[ "${ISE_CLEAN_INSTALL}" -eq "1" ]] ; then
    # sanity check that all variables were set
    if [[ -z ${ISE_DEVICE+x} ]] ; then
        echo "Installer script called without all environment variables set!"
        sleep 999

        exit 1
    fi

    if [[ -n "$IS_EFI" ]] ; then
        sudo parted --script "${ISE_DEVICE}" \
            mklabel gpt                      \
            mkpart primary 1MiB 500MiB       \
            set 1 esp on                     \
            mkpart primary 500MiB 100% || {
                echo "Failed to partition '${ISE_DEVICE}'"
                sleep 999

                exit 1
            }
        ISE_EFI=$(lsblk ${ISE_DEVICE} -no path | sed '2!d')
        sudo mkfs.vfat ${ISE_EFI} || {
            echo "Failed to format EFI partition ${IS_EFI}"
            sleep 999

            exit 1
        }
        ISE_ROOT=$(lsblk ${ISE_DEVICE} -no path | sed '3!d')

        echo "Device Path: ${ISE_DEVICE}"
    else
        sudo parted --script "${ISE_DEVICE}" \
            mklabel msdos                    \
            mkpart primary 1MiB 100% || {
                echo "Failed to partition '${ISE_DEVICE}'"
                sleep 999

                exit 1
            }
        ISE_ROOT=$(lsblk ${ISE_DEVICE} -no path | sed '2!d')

        echo "Device Path: ${ISE_DEVICE}"
    fi
fi

if [[ -z "${ISE_EFI}" ]] && [[ -n "$IS_EFI" ]] ; then
    echo "Unknown EFI partition"
    sleep 999
    
    exit 1
fi

if [[ -n "$IS_EFI" ]] ; then
    echo ":: Setting 'EFI' Label to ${ISE_EFI}"
    # Make sure EFI parititon
    sudo fatlabel ${ISE_EFI} EFI || {
        echo "Failed to change EFI partition label"
        sleep 999

        exit 1
    }
fi

# sanity check that all variables were set
if [[ -z ${ISE_ROOT+x} ]] ; then
    echo "Installer script called without all environment variables set!"
    sleep 999

    exit 1
fi

SYSROOT="/.installer-root"

sudo mkdir -p ${SYSROOT}

echo ":: Formatting ${ISE_ROOT}"
sudo mkfs.ext4 -F ${ISE_ROOT} >/dev/null || {
    echo "Failed to mkfs.ext4 ${ISE_ROOT}"
    sleep 999

    exit 1
}

echo ":: Mounting ${ISE_ROOT} on ${SYSROOT}"
sudo mount ${ISE_ROOT} ${SYSROOT} || {
    echo "Failed to mount ${ISE_ROOT}"
    sleep 999

    exit 1
}

echo ":: Creating System Hierarchy"
sudo mkdir -p ${SYSROOT}/boot || {
    sudo umount ${SYSROOT}
    echo "failed to create required sysroot path '${SYSROOT}/boot'"
    sleep 999

    exit 1
}

if [[ -n "$IS_EFI" ]] ; then
    sudo mkdir -p ${SYSROOT}/efi || {
        echo "failed to create efi directory"
        sleep 999

        exit 1
    }
    sudo mount ${ISE_EFI} ${SYSROOT}/efi || {
        sudo umount ${ISE_ROOT}
        echo "Failed to mount ${ISE_EFI} ${SYSROOT}/boot"
        sleep 999

        exit 1
    }
fi

cleanup() {
    [[ -n "$IS_EFI" ]] && sudo umount ${SYSROOT}/efi/
    sudo umount ${SYSROOT}
}

trap cleanup EXIT

if [ -d /sysroot/ostree/repo ] ; then
    echo "OStree based installation"
    sudo mkdir -p ${SYSROOT}/ostree/repo || {
        echo "failed to create repo dir"
        sleep 999

        exit 1
    }

    echo ":: Creating OStree filesystem"
    sudo ostree admin init-fs ${SYSROOT} || {
        echo "failed to creating ostree filesystem"
        sleep 999

        exit 1
    }

    echo ":: Initializing OStree filesystem"
    sudo ostree admin os-init --sysroot=${SYSROOT} rlxos || {
        echo "failed to initialize os roots"
        sleep 999

        exit 1
    }

    sudo ostree config --repo=${SYSROOT}/ostree/repo set sysroot.bootloader none
    sudo ostree config --repo=${SYSROOT}/ostree/repo set sysroot.bootprefix true

    echo ":: Cloning OStree into the device (this might take a while)"
    sudo ostree --repo=${SYSROOT}/ostree/repo pull-local "/ostree/repo" @@OSTREE_BRANCH@@ || {
        echo "failed to clone OStree repository"
        sleep 999

        exit 1
    }

    ROOT_UUID=$(sudo lsblk -no uuid ${ISE_ROOT})

    echo ":: Deploying OStree"
    sudo ostree admin deploy --os="rlxos"   \
        --sysroot="${SYSROOT}" @@OSTREE_BRANCH@@ \
        --karg="rw" --karg="quiet" --karg="splash" \
        --karg="root=UUID=$ROOT_UUID" || {
        echo "failed to deploy OStree"
        sleep 999

        exit 1
    }

    echo ":: Setting up origin"
    sudo ostree admin set-origin --sysroot="${SYSROOT}" \
        --index=0 rlxos https://ostree.rlxos.dev/ @@OSTREE_BRANCH@@ || {
        echo "failed to setup origin"
        sleep 999

        exit 1
    }

    sudo ostree remote delete rlxos --repo=${SYSROOT}/ostree/repo

    sudo mkdir -p ${SYSROOT}/proc

    echo ":: Installing Bootloader"
    if [[ -n "${IS_EFI}" ]] ; then
        sudo grub-install --boot-directory=${SYSROOT}/boot --efi-directory=${SYSROOT}/efi --root-directory=${SYSROOT} --target=x86_64-efi
    else
        sudo grub-install --boot-directory=${SYSROOT}/boot --root-directory=${SYSROOT} --target=i386-pc ${ISE_BOOT_DEVICE}
    fi

    # TODO: fix this hack
    (cd ${SYSROOT}/boot/loader; sudo /lib/ostree/ostree-grub-generator . grub.cfg)

    sudo install -D -m 0644 /dev/stdin ${SYSROOT}/boot/grub/grub.cfg << "EOF"
set timeout=5
if [ -s $prefix/grubenv ] ; then
    set have_grubenv=true
    load_env
fi

if [ x"${feature_menuentry_id}" = xy ] ; then
    menuentry_id_option="--id"
else
    menuentry_id_option=""
fi

export menuentry_id_option

if [ "${prev_saved_entry}" ] ; then
    set saved_entry="${prev_saved_entry}"
    save_env saved_entry
    set pre_saved_entry=
    save_env prev_saved_entry
    set boot_once=true
fi

function savedefault {
    if [ -z "${boot_once}" ] ; then
        saved_entry="${chosed}"
        save_env saved_entry
    fi
}

function load_video {
    if [ x$feature_all_video_module = xy ] ; then
        insmod all_video
    else
        insmod efi_gop
        insmod efi_uga
        insmod ieee1275_fb
        insmod vbe
        insmod vga
        insmod video_bochs
        insmod video_cirrus
    fi
}

font=unicode

if loadfont $font ; then
    set gfxmode=auto
    load_video
    insmod gfxterm
    set locale_dir=$prefix/locale
    set lang=en_IN
    insmod gettext
fi

terminal_output gfxterm
if [ "${recordfail}" = 1 ] ; then
    set timeout=30
else
    if [ x$feature_timeout_style = xy ] ; then
        set timeout_style=menu
        set timeout=5
    else
        set timeout=5
    fi
fi

function gfxmode {
    set gfxpayload="${1}"
}

set linux_gfx_mode=
export linux_gfx_mode

insmod part_gpt
insmod ext2

configfile /boot/loader/grub.cfg
EOF

    sudo ostree config --repo=${SYSROOT}/ostree/repo set sysroot.bootloader grub2
else
    if [[ -n "$IS_EFI" ]] ; then
        sudo mkdir -p ${SYSROOT}/efi || {
            echo "failed to create efi directory"
            sleep 999

            exit 1
        }
        sudo mount ${ISE_EFI} ${SYSROOT}/efi || {
            sudo umount ${ISE_ROOT}
            echo "Failed to mount ${ISE_EFI} ${SYSROOT}/efi"
            sleep 999

            exit 1
        }
    fi

    echo "PKGUPD based installation"
    echo ":: Installing System Image"
    sudo unsquashfs -q -n -f -d ${SYSROOT} /run/initramfs/live/LiveOS/squashfs.img || {
        echo "failed to install system image"
        sleep 999

        exit 1
    }

    KERNEL_VERSION=$(ls -1 ${SYSROOT}/lib/modules/ | head -n1)

    sudo chroot ${SYSROOT} /bin/bash -e << EOT
    echo ":: Creating file hierarchy"
    mkdir -p /dev /sys /proc

    mount -t devtmpfs none /dev
    mount -t sysfs    none /sys
    mount -t proc     none /proc

    if [[ -n "${IS_EFI}" ]] ; then
        mount -t efivarfs none /sys/firmware/efi/efivars
    fi

    echo ":: Generating initramfs"
    dracut /boot/initramfs-${KERNEL_VERSION}.img

    echo ":: Installing kernel"
    cp /lib/modules/${KERNEL_VERSION}/bzImage /boot/vmlinuz-${KERNEL_VERSION}

    echo ":: Installing Bootloader"
    if [[ -n "${IS_EFI}" ]] ; then
        grub-install --boot-directory=/boot --efi-directory=/efi --target=x86_64-efi
    else
        grub-install --boot-directory=/boot --target=i386-pc ${ISE_BOOT_DEVICE}
    fi

    echo ":: Generating bootloader configuration"
    update-grub
EOT

if [[ $? -ne 0 ]] ; then
    echo "Failed to configure system"
    sleep 999

    exit 1
fi

fi


# Sleep for 2 seconds
sleep 5

exit 0