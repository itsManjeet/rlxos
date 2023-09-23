package cloner

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/utils"
	"strconv"
	"strings"
	"syscall"
)

type ProgressFunction func(int, string)

type Bootloader string

const (
	BOOTLOADER_GRUB Bootloader = "grub"
	BOOTLOADER_NONE Bootloader = "none"
)

type Cloner struct {
	PartitionType string
	ImageVersion  int
	Bootloader    Bootloader
	IsEfi         bool
	EfiPartition  string
	PrettyName    string
	BootDisk      string
}

func (c *Cloner) DiskofParition(partition string) (string, error) {
	blockClass, err := os.Readlink(path.Join("/sys/class/block/" + path.Base(partition)))
	if err != nil {
		return "", fmt.Errorf("failed to readlink partition block %s, %v", path.Base(partition), err)
	}

	return path.Join("/dev", path.Base(path.Dir(blockClass))), nil
}

func (c *Cloner) Clone(partition, imagePath string) error {
	log.Println("Creating installation directory")
	tmpdir, err := os.MkdirTemp(os.TempDir(), "swupd-*")
	if err != nil {
		return fmt.Errorf("failed to create temporary dir %v", err)
	}
	defer os.RemoveAll(tmpdir)

	log.Printf("Mounting %s [%s] %s\n", partition, tmpdir, c.PartitionType)
	if err := syscall.Mount(partition, tmpdir, c.PartitionType, 0, ""); err != nil {
		return fmt.Errorf("failed to mount partition %s (%s) -> %s", partition, c.PartitionType, tmpdir)
	}
	defer syscall.Unmount(tmpdir, syscall.MNT_FORCE)

	log.Println("Creating required directories")
	for _, dir := range []string{"images", "layers", "apps", "boot"} {
		p := path.Join(tmpdir, "sysroot", dir)
		log.Println("  =>", p)
		if err := os.MkdirAll(p, 0755); err != nil {
			return fmt.Errorf("failed to create required directories %s (%v)", p, err)
		}
	}

	if c.ImageVersion == 0 {
		var err error
		versionString := path.Base(imagePath)
		if idx := strings.Index(versionString, "."); idx != -1 {
			versionString = versionString[:idx]
		}
		c.ImageVersion, err = strconv.Atoi(versionString)
		if err != nil {
			return fmt.Errorf("image version must be a integer %s, %v", versionString, err)
		}
	}

	log.Println("Installing system image", imagePath)
	if err := utils.CopyFile(imagePath, path.Join(tmpdir, "sysroot", "images", fmt.Sprint(c.ImageVersion))); err != nil {
		return fmt.Errorf("failed to install system image %v", err)
	}

	if c.Bootloader == BOOTLOADER_NONE {
		return nil
	}

	log.Println("Installing bootloader")
	if err := os.MkdirAll(path.Join(tmpdir, "sysroot", "boot", "grub"), 0755); err != nil {
		return fmt.Errorf("failed to create boot directories, %v", err)
	}

	if c.IsEfi {
		log.Println("Setting up EFI partition")

		if c.EfiPartition == "" {
			output, err := exec.Command("sh", "-c", "lsblk -no path,parttypename | grep 'EFI System Partition'").CombinedOutput()
			if err != nil {
				return fmt.Errorf("failed to detect EFI partition %s, %v", string(output), err)
			}

			c.EfiPartition = strings.Trim(string(output), " \n")
		}
		efiPath := path.Join(tmpdir, "sysroot", "efi")
		if err := os.MkdirAll(efiPath, 0755); err != nil {
			return fmt.Errorf("failed to create EFI directory %s, %v", efiPath, err)
		}

		EFI_PART_TYPE := "fat32"
		if len(os.Getenv("EFI_PART_TYPE")) != 0 {
			EFI_PART_TYPE = os.Getenv("EFI_PART_TYPE")
		}

		if err := syscall.Mount(c.EfiPartition, efiPath, EFI_PART_TYPE, 0, ""); err != nil {
			return fmt.Errorf("failed to mount EFI Partition")
		}
	}
	defer syscall.Unmount(c.EfiPartition, syscall.MNT_FORCE)

	if c.BootDisk == "" {
		c.BootDisk, err = c.DiskofParition(partition)
		if err != nil {
			return err
		}
	}

	if c.IsEfi {
		if data, err := exec.Command("grub-install", "--recheck", "--bootloader-id="+c.PrettyName, "--target=x86_64-efi", "--efi-directory="+path.Join(tmpdir, "sysroot", "efi"), "--root-directory="+tmpdir, "--boot-directory="+path.Join(tmpdir, "sysroot", "boot")).CombinedOutput(); err != nil {
			return fmt.Errorf("failed to install bootloader %s, %v", string(data), err)
		}
	} else {
		if data, err := exec.Command("grub-install", "--recheck", "--root-directory="+tmpdir, "--boot-directory="+path.Join(tmpdir, "sysroot", "boot"), c.BootDisk).CombinedOutput(); err != nil {
			return fmt.Errorf("failed to install bootloader %s, %v", string(data), err)
		}
	}

	var kernelVersion string
	{
		output, err := exec.Command("uname", "-r").CombinedOutput()
		if err != nil {
			return fmt.Errorf("failed to get kernel version %s, %v", string(output), err)
		}
		kernelVersion = strings.Trim(string(output), " \n")
	}

	log.Println("Installing kernel image")
	if err := utils.CopyFile(path.Join("/", "lib", "modules", kernelVersion, "bzImage"), path.Join(tmpdir, "sysroot", "boot", "vmlinuz-"+kernelVersion)); err != nil {
		return fmt.Errorf("failed to install kernel image %v", err)
	}

	log.Println("Generating initramfs")
	if data, err := exec.Command("mkinitramfs", "-o="+path.Join(tmpdir, "sysroot", "boot", "initramfs-"+kernelVersion+".img"), "--no-plymouth").CombinedOutput(); err != nil {
		return fmt.Errorf("failed to generate initramfs %s, %v", string(data), err)
	}

	log.Println("Getting UUID for", partition)
	grubRootPath := partition
	if data, err := exec.Command("sh", "-c", fmt.Sprintf("lsblk -o path,uuid  | grep %s | awk '{print $2}'", partition)).CombinedOutput(); err == nil {
		grubRootPath = strings.Trim(string(data), " \n")
		if len(grubRootPath) == 0 {
			grubRootPath = partition
		} else {
			grubRootPath = "UUID=" + grubRootPath
		}
	}

	log.Println("Writing bootloader configuration")
	if err := ioutil.WriteFile(path.Join(tmpdir, "sysroot", "boot", "grub", "grub.cfg"), []byte(fmt.Sprintf(`
set timeout=5
set default="%s"

menuentry "%s" {
	insmod all_video
	linux /sysroot/boot/vmlinuz-%s rw rd.image=%d root=%s
	initrd /sysroot/boot/initramfs-%s.img
}

	`, c.PrettyName, c.PrettyName, kernelVersion, c.ImageVersion, grubRootPath, kernelVersion)), 0644); err != nil {
		return fmt.Errorf("failed to write bootloader configuration %v", err)
	}

	return nil
}
