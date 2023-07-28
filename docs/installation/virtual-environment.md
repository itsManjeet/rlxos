# Virtual Environment

## QEMU:
To enable UEFI support in QEMU for rlxOS, use the following command line option while starting the virtual machine:
```
qemu-system-x86_64 -bios OVMF.fd [...other options...]
```
Make sure to replace "OVMF.fd" with the path to your UEFI firmware image (e.g., "OVMF_CODE.fd" or "OVMF.fd" from the OVMF package).

## VirtualBox:
To enable UEFI support in VirtualBox for rlxOS, follow these steps:
1. Create a new virtual machine for rlxOS.
2. In the VM settings, go to the "System" tab.
3. Under the "Motherboard" tab, check the "Enable EFI (special OSes only)" option to enable UEFI support.
4. Continue with the rlxOS installation process.

## VMware:
To enable UEFI support in VMware for rlxOS, follow these steps:
1. Create a new virtual machine for rlxOS.
2. During the VM creation process, choose "rlxOS" or an appropriate version that supports UEFI as the guest OS.
3. Continue with the rlxOS installation process, ensuring you use a UEFI-supported ISO.

Enabling UEFI support in these virtualization platforms will ensure compatibility and optimal performance for rlxOS in your virtual environment.