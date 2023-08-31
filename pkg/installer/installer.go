package installer

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/osinfo"
	"rlxos/pkg/utils"
	"strconv"
	"strings"
	"syscall"
	"unicode"
)

type ProgressFunction func(int, string)

type Installer struct {
	ParititonType string
	ImageVersion  int
	KernelVersion string
	Timeout       int
	PrettyName    string
	ISOLabel      string
	Progress      ProgressFunction
}

func New(progress ProgressFunction) (*Installer, error) {
	os_release, err := osinfo.Open(path.Join("/", "usr", "lib", "os-release"))
	if err != nil {
		return nil, err
	}
	curver_str, ok := os_release["IMAGE_VERSION"]
	if !ok {
		return nil, fmt.Errorf("missing required key 'IMAGE_VERSION' in os-release")
	}

	imageVersion, err := strconv.Atoi(curver_str)
	if err != nil {
		return nil, err
	}

	kernelVersion, err := exec.Command("uname", "-r").CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("failed to get kernel version %s, %v", string(kernelVersion), err)
	}
	return &Installer{
		ParititonType: "ext4",
		ImageVersion:  imageVersion,
		KernelVersion: strings.TrimSuffix(string(kernelVersion), "\n"),
		Progress:      progress,
		ISOLabel:      "RLXOS",
		PrettyName:    "RLXOS Linux",
		Timeout:       10,
	}, nil
}

func (i *Installer) partitionToDisk(part string) string {
	return strings.TrimRightFunc(part, unicode.IsDigit)
}

func (i *Installer) Install(part string) error {
	log.Println("Setting up installation")
	sysroot := path.Join("/", "sysroot")
	if err := os.MkdirAll(path.Join("/", "sysroot"), 0755); err != nil {
		return fmt.Errorf("failed to setup installation process, %v", err)
	}
	defer os.Remove(sysroot)

	log.Println("Mounting partition", part)
	if err := syscall.Mount(part, sysroot, i.ParititonType, 0, ""); err != nil {
		return fmt.Errorf("failed to mount partition %s (%s) -> %s", part, i.ParititonType, sysroot)
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

	ISO_PATH := path.Join("/", "/run", "iso")
	log.Println("Installing system image")
	rootfs := path.Join(ISO_PATH, "usr.squashfs")
	rootfs, _ = os.Readlink(rootfs)
	rootfs = path.Join(ISO_PATH, rootfs)
	if err := utils.CopyFile(rootfs, path.Join(sysroot, "rlxos", "system", fmt.Sprint(i.ImageVersion))); err != nil {
		return fmt.Errorf("failed to install system image %v", err)
	}

	log.Println("Installing bootloader")
	if err := os.MkdirAll(path.Join(sysroot, "boot", "grub"), 0755); err != nil {
		return fmt.Errorf("failed to create boot directories, %v", err)
	}
	if data, err := exec.Command("grub-install", "--recheck", "--root-directory="+sysroot, "--boot-directory="+path.Join(sysroot, "boot"), i.partitionToDisk(part)).CombinedOutput(); err != nil {
		return fmt.Errorf("failed to install bootloader %s, %v", string(data), err)
	}

	log.Println("Installing kernel image")
	if err := utils.CopyFile(path.Join("/", "lib", "modules", i.KernelVersion, "bzImage"), path.Join(sysroot, "boot", "vmlinuz-"+i.KernelVersion)); err != nil {
		return fmt.Errorf("failed to install kernel image %v", err)
	}

	log.Println("Generating initramfs")
	if data, err := exec.Command("mkinitramfs", "-o="+path.Join(sysroot, "boot", "initramfs-"+i.KernelVersion+".img"), "--no-plymouth").CombinedOutput(); err != nil {
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
set default="%s"

menuentry "%s" {
	insmod all_video
	linux /boot/vmlinuz-%s rw rd.image=%d root=%s
	initrd /boot/initramfs-%s.img
}

	`, i.Timeout, i.PrettyName, i.PrettyName, i.KernelVersion, i.ImageVersion, grubRootPath, i.KernelVersion)), 0644); err != nil {
		return fmt.Errorf("failed to write bootloader configuration %v", err)
	}

	return nil
}
