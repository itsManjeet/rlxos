if [[ ! -e disk.qcow2 ]]; then
    echo "Creating Disk"
    qemu-img create -f qcow2 disk.qcow2 10G
fi

ISO="${1}"
shift
qemu-system-x86_64 -m 4G \
    -vga virtio \
    -display default \
    -usb \
    -device usb-tablet \
    -smp 2 \
    -cdrom ${ISO} \
    -drive file=disk.qcow2,if=virtio \
    -cpu host -enable-kvm ${@}
