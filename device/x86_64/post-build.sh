#!/bin/sh

set -e

BOARD_DIR=$(dirname "$0")

INITRAMFS_DIR=$(mktemp -d /tmp/initramfs.XXXXXXXXXX)
UNSORTED=$(mktemp /tmp/unsorted.XXXXXXXX)

for dir in dev boot etc mnt/root proc sys run ; do
    mkdir -p $INITRAMFS_DIR/$dir
done

for dir in bin lib share ; do
    mkdir -p $INITRAMFS_DIR/usr/$dir
done

ln -s bin $INITRAMFS_DIR/usr/sbin
ln -s usr/bin $INITRAMFS_DIR/bin
ln -s usr/bin $INITRAMFS_DIR/sbin

ln -s lib $INITRAMFS_DIR/usr/lib64
ln -s usr/lib $INITRAMFS_DIR/lib
ln -s usr/lib $INITRAMFS_DIR/lib64

mkdir -p $INITRAMFS_DIR/lib/modules/


for bin in bin/sh bin/mount bin/sleep bin/grep bin/sort bin/mkdir bin/head bin/awk sbin/findfs sbin/switch_root sbin/udevd bin/udevadm bin/kmod; do
    install -vm755 $TARGET_DIR/$bin $INITRAMFS_DIR/$bin
    objdump -p $INITRAMFS_DIR/$bin | grep NEEDED | awk '{print $2}' >> $UNSORTED
done

for i in ata_id scsi_id cdrom_id mtd_probe v4l_id libinput-device-group dmi_memory_id ; do
    install -vDm755 $TARGET_DIR/lib/udev/$i -t $INITRAMFS_DIR/lib/udev/
    objdump -p $INITRAMFS_DIR/lib/udev/$i | grep NEEDED | awk '{print $2}' >> $UNSORTED
done

req=$(cat $UNSORTED | sort | uniq)
for lib in $req ; do
    objdump -p $TARGET_DIR/lib/$lib | grep NEEDED | awk '{print $2}' >> $UNSORTED
done

for i in $TARGET_DIR/lib/udev/rules.d/*.rules ; do
    install -vDm0644 $i -t $INITRAMFS_DIR/lib/udev/rules.d/
done

for i in depmod insmod lsmod modinfo modprobe rmmod ; do
    ln -sv kmod $INITRAMFS_DIR/usr/bin/$i
done

ln -sv libc.so $INITRAMFS_DIR/usr/lib/ld-musl-x86_64.so.1

for lib in $(cat $UNSORTED | sort | uniq) ; do
    cp $TARGET_DIR/lib/$lib $INITRAMFS_DIR/usr/lib/
done

KERNEL_VERSION=$(ls -1 $TARGET_DIR/lib/modules/ | head -n1)

for mod in crypto fs lib ; do
    FTGT="$FTGT $TARGET_DIR/lib/modules/$KERNEL_VERSION/kernel/$mod"
done

for driver in block ata md firewire nvme parport cdrom input scsi message pcmcia virtio hid usb/host usb/storage ; do
    FTGT="$FTGT $TARGET_DIR/lib/modules/$KERNEL_VERSION/kernel/drivers/$driver"
done

mkdir -p $INITRAMFS_DIR/lib/modules/$KERNEL_VERSION

for mod in $(find $FTGT -type f -name "*.ko*" 2>/dev/null) ; do
    mod=$(echo $mod | sed "s#$TARGET_DIR##g")
    install -vDm0644 $TARGET_DIR/$mod $INITRAMFS_DIR/$mod
done

cp $TARGET_DIR/lib/modules/$KERNEL_VERSION/modules.* $INITRAMFS_DIR/lib/modules/$KERNEL_VERSION/

awk -F'/' '{ print "kernel/" $NF }' $TARGET_DIR/lib/modules/$KERNEL_VERSION/modules.order > $INITRAMFS_DIR/lib/modules/$KERNEL_VERSION/modules.order
depmod -a -b $INITRAMFS_DIR $KERNEL_VERSION

cat > $INITRAMFS_DIR/init << "EOF"
#!/bin/sh

export PATH=/bin:/sbin

ROOT=
ROOTFLAGS=
DELAY=2
INIT=/system/core/init
SYSTEM=
SPLASH=
DELAY=2

rescue() {
    echo "ERROR: $@"
    echo "Dropping into rescue shell"
    /bin/sh
}

mount -t proc       none /proc  -o nosuid,noexec,nodev
mount -t sysfs      none /sys   -o nosuid,noexec,nodev
mount -t devtmpfs   none /dev   -o mode=0755,nosuid
mount -t tmpfs      none /run   -o nosuid,nodev,mode=0755

for arg in $(cat /proc/cmdline); do
    case "$arg" in
        root=*)         ROOT="${arg#*=}"        ;;
        root.flags=*)   ROOTFLAGS="${arg#*=}"   ;;
        delay=*)        DELAY="${arg#*=}"       ;;
        init=*)         INIT="${arg#*=}"        ;;
        live)           LIVE=1                  ;;
        system)         SYSTEM="${arg#*=}"      ;;
    esac
done

udevd --daemon --resolve-names=never
udevadm trigger --action=add --type=subsystems
udevadm trigger --action=add --type=devices
udevadm trigger --action=change --type=devices

udevadm settle

sleep $DELAY

count=0

while [ $count -lt 10 ] ; do
    RESOLVED_ROOT=$(findfs "$ROOT" 2>/dev/null)
    if [ -n $RESOLVED_ROOT ] && [ -e $RESOLVED_ROOT ] ; then
        break
    fi

    echo "Waiting for root filesystem"
    sleep $DELAY
    count=$((count+1))
done

if [ -z "$RESOLVED_ROOT" ] || [ ! -e "$RESOLVED_ROOT" ] ; then
    rescue "failed to find $ROOT root filesystem"
fi

ROOT=$RESOLVED_ROOT
SYSROOT='/sysroot'
mkdir -p $SYSROOT

LIVE_DIR='/run/live'
ROOT_DIR='/run/root'

mkdir -p $LIVE_DIR/rw $LIVE_DIR/ro $LIVE_DIR/work

if [ -n "$LIVE" ] ; then
    ROOT_DIR='/run/iso'
    mkdir -p $ROOT_DIR
    SYSTEM="rootfs.sfs"
else
    if [ -z "$SYSTEM" ] ; then
        SYSTEM="LABEL=$(ls -1 /dev/disk/by-label/ | grep "rlxos_image_" | sort -r | head -n1 | awk '{print $1}')"
    fi
    if [ -z "$SYSTEM" ] ; then
        rescue "failed to found system image"
        sleep 9999
    fi
fi

mount -t auto $ROOT $ROOT_DIR || rescue "failed to mount $ROOT at $ROOT_DIR"
mount $ROOT_DIR/$SYSTEM $LIVE_DIR/ro || rescue "failed to system root image"
mount overlay -t overlay -o lowerdir=$LIVE_DIR/ro,upperdir=$LIVE_DIR/rw,workdir=$LIVE_DIR/work $SYSROOT || rescue "failed to create overlay setup"

for dir in proc sys dev run ; do
    mkdir -p $SYSROOT/$dir
done

mount --move /proc $SYSROOT/proc
mount --move /sys $SYSROOT/sys
mount --move /dev $SYSROOT/dev
mount --move /run $SYSROOT/run

exec switch_root $SYSROOT "$INIT" "$@"

EOF

chmod +x "$INITRAMFS_DIR"/init


which tree 2>/dev/null && tree "$INITRAMFS_DIR"

(
    cd "$INITRAMFS_DIR"
    find . | LANG=C cpio -o -H newc --quiet | gzip --best > "$BINARIES_DIR"/initramfs.img
)

rm -rf "$INITRAMFS_DIR" "$UNSORTED"
