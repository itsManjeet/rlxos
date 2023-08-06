package backend

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/utils"
	swupd "rlxos/src/swupd/backend"
	"syscall"
)

type Backend struct {
	ParititonType string
	ImageVersion  int
	KernelVersion string
}

func New() (*Backend, error) {
	imageVersion, err := swupd.GetCurrentVersion()
	if err != nil {
		return nil, fmt.Errorf("failed to get current version %v", err)
	}
	kernelVersion, err := exec.Command("uname", "-r").CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("failed to get kernel version %s, %v", string(kernelVersion), err)
	}
	return &Backend{
		ParititonType: "ext4",
		ImageVersion:  imageVersion,
		KernelVersion: string(kernelVersion),
	}, nil
}

func (b *Backend) Install(part string) error {
	log.Println("Setting up installation")
	sysroot := path.Join("/", "sysroot")
	if err := os.MkdirAll(path.Join("/", "sysroot"), 0755); err != nil {
		return fmt.Errorf("failed to setup installation process, %v", err)
	}
	defer os.Remove(sysroot)

	log.Println("Mounting partition", part)
	if err := syscall.Mount(part, sysroot, b.ParititonType, 0, ""); err != nil {
		return fmt.Errorf("failed to mount partition %s (%s) -> %s", part, b.ParititonType, sysroot)
	}
	defer syscall.Unmount(sysroot, syscall.MNT_FORCE)

	log.Println("Creating required directories")
	for _, dir := range []string{"system", "cache", "config"} {
		p := path.Join(sysroot, "rlxos", dir)
		log.Println("  =>", p)
		if err := os.MkdirAll(p, 0755); err != nil {
			return fmt.Errorf("failed to create required directories %s (%v)", p, err)
		}
	}

	log.Println("Installing system image")
	rootfs := path.Join("/run/iso/rootfs.img")
	if err := utils.CopyFile(rootfs, path.Join(sysroot, "system", fmt.Sprint(b.ImageVersion))); err != nil {
		return fmt.Errorf("failed to install system image %v", err)
	}

	log.Println("Installing bootloader")
	if err := os.MkdirAll(path.Join(sysroot, "boot", "grub"), 0755); err != nil {
		return fmt.Errorf("failed to create boot directories, %v", err)
	}
	if data, err := exec.Command("grub-install", "--recheck", "--root-directory="+sysroot, "--boot-directory="+path.Join(sysroot, "boot"), part).CombinedOutput(); err != nil {
		return fmt.Errorf("failed to install bootloader %s, %v", string(data), err)
	}

	log.Println("Installing kernel image")
	if err := utils.CopyFile(path.Join("/", "lib", "modules", b.KernelVersion, "bzImage"), path.Join(sysroot, "boot", "vmlinuz-"+b.KernelVersion)); err != nil {
		return fmt.Errorf("failed to install kernel image %v", err)
	}

	log.Println("Generating initramfs")
	if data, err := exec.Command("mkinitramfs", "-o="+path.Join(sysroot, "boot", "initramfs-"+b.KernelVersion+".img"), "--no-plymouth").CombinedOutput(); err != nil {
		return fmt.Errorf("failed to generate initramfs %s, %v", string(data), err)
	}

	return nil
}
