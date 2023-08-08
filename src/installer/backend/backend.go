package backend

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/utils"
	swupd "rlxos/src/swupd/backend"
	"strings"
	"syscall"
	"unicode"
)

type ProgressFunction func(int, string)

type Backend struct {
	ParititonType string
	ImageVersion  int
	KernelVersion string
	Timeout       int
	PrettyName    string
	Progress      ProgressFunction
}

func New(progress ProgressFunction) (*Backend, error) {
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
		Progress:      progress,
		PrettyName:    "RLXOS Linux",
		Timeout:       10,
	}, nil
}

func (b *Backend) partitionToDisk(part string) string {
	return strings.TrimRightFunc(part, unicode.IsDigit)
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
	if data, err := exec.Command("grub-install", "--recheck", "--root-directory="+sysroot, "--boot-directory="+path.Join(sysroot, "boot"), b.partitionToDisk(part)).CombinedOutput(); err != nil {
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

	log.Println("Getting UUID for", part)
	grubRootPath := part
	if data, err := exec.Command("sh", "-c", fmt.Sprintf("lsblk -o path,uuid  | grep %s | awk '{print $2}'", part)).CombinedOutput(); err == nil {
		grubRootPath = strings.Trim(string(data), " \n")
		if len(grubRootPath) == 0 {
			grubRootPath = part
		} else {
			grubRootPath = "UUID=" + grubRootPath
		}
	}

	log.Println("Writing bootloader configuration")
	if err := ioutil.WriteFile(path.Join(sysroot, "boot", "grub", "grub.cfg"), []byte(fmt.Sprintf(`
set timeout=%d
set default="%s Installer"

menuentry "%s Installer" {
	linux /boot/vmlinuz-%s rw system=%d root=UUID=%s
	initrd /boot/initramfs-%s.img
}

	`, b.Timeout, b.PrettyName, b.PrettyName, b.KernelVersion, b.ImageVersion, grubRootPath, b.KernelVersion)), 0644); err != nil {
		return fmt.Errorf("failed to write bootloader configuration %v", err)
	}

	return nil
}
