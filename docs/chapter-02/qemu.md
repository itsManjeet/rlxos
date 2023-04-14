# QEMU

> QEMU is a free and open-source emulator. It emulates the machine's processor through dynamic binary translation and provides a set of different hardware and device models for the machine, enabling it to run a variety of guest operating systems

Website: [https://www.qemu.org/](https://www.qemu.org/)

## Installations
QEMU is packaged by most Linux distributions:

**rlxos GNU/Linux:**
```
pkgupd install qemu
```

**ArchLinux:** 
```
pacman -S qemu
```

**Debian/Ubuntu:** 
```
apt-get install qemu
```

**Fedora:**
```
dnf install @virtualization
```

**Gentoo:**
```
emerge --ask app-emulation/qemu
```

## Virtual Disk
We need a virtual disk that is needed to emulate the storage device and on that device we are going to install our rlxos.

```
    qemu-img create disk.img 10G
```

You can configure the disk size as per your requirement, rlxos need atleast 10GiB of disk space.

## KVM Acceleration

QEMU is a type 2 hypervisor and emulate all of the virtual machine's resources, which can be extremely slow. Using **KVM** (Linux Kernel Module), which is a type 1 hypervisor for full virtualization and can be used as accelerator so that the physical CPU virtualization extensions can be used

So we need to check if the system supports KVM virtualization (most hardware does).

```
file /dev/kvm
```

and it should print something like
```
/dev/kvm: character special (../...)
```


## Starting virtual machine
```
qemu-system-x86_64  \
    -m 4G           \
    -vga virtio     \
    -display default,show-cursor=on \
    -usb \
    -smp 2 \
    -cdrom **/path/to/rlxos.iso** \
    -drive file=disk.img,if=qcow2 \
    -enable-kvm \
    -cpu host \
```

### Parameters you can customize
| Parameter   | Description                |
| ----------- | -------------------------- |
| -m          | virtual memory to allocate |
| -vga        | graphics driver            |
| -smp        | cpu core                   |
| -cdrom      | path to rlxos ISO          |
| -enable-kvm | if KVM is available        |



**Now follow the installation and partition GUIDE as it is**