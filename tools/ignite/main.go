package main

import (
	"flag"
	"fmt"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"path/filepath"

	"rlxos.dev/pkg/ensure"
)

const (
	KERNEL_VERSION = "6.15.4"
)

var (
	projectPath string
	cachePath   string
	devicePath  string

	runTest bool
	cpu     int
	memory  int
	vnc     int
	debug   bool
	clean   bool

	kernelVersion string

	deviceCachePath string
	toolchainPath   string
	imagesPath      string
	sourcesPath     string
	buildPath       string
	sysrootPath     string

	systemPath    string
	initramfsPath string
	kernelPath    string

	device Device
)

func init() {
	cur, _ := os.Getwd()
	flag.StringVar(&projectPath, "project-path", cur, "Project path")
	flag.StringVar(&cachePath, "cache-path", "", "Cache path")
	flag.StringVar(&devicePath, "device", "", "Device path")
	flag.BoolVar(&clean, "clean", false, "Clean build targets")
	flag.BoolVar(&runTest, "test", false, "run test")
	flag.IntVar(&cpu, "cpu", 1, "number of CPU for enumlation")
	flag.IntVar(&memory, "memory", 512, "memory allocated for emulation (in MBs)")
	flag.IntVar(&vnc, "vnc", -1, "VNC port")
	flag.BoolVar(&debug, "debug", false, "Wait for debugger to connect")
	flag.StringVar(&kernelVersion, "kernel", KERNEL_VERSION, "Specify kernel version")

}

func main() {
	flag.Parse()
	ensure.Success(checkup(), "failed to find required tools and libraries")
	ensure.Success(prepareDirectories(), "failed to prepare directories")

	os.Setenv("PATH", filepath.Join(toolchainPath, "bin")+":"+os.Getenv("PATH"))
	os.Setenv("CC", device.TargetTriple()+"-gcc")
	os.Setenv("CXX", device.TargetTriple()+"-g++")
	os.Setenv("LD", device.TargetTriple()+"-ld")
	os.Setenv("RANLIB", device.TargetTriple()+"-ranlib")
	os.Setenv("STRIP", device.TargetTriple()+"-strip")
	os.Setenv("AR", device.TargetTriple()+"-ar")
	os.Setenv("ARCH", device.Arch)
	os.Setenv("CARCH", device.ArchAlias())
	os.Setenv("TARGET_TRIPLE", device.TargetTriple())
	os.Setenv("SYSROOT", sysrootPath)
	os.Setenv("SOURCES_PATH", sourcesPath)
	os.Setenv("IMAGES_PATH", imagesPath)
	os.Setenv("DEVICE_PATH", devicePath)
	os.Setenv("SYSTEM_PATH", systemPath)
	os.Setenv("KERNEL_VERSION", kernelVersion)

	toolchainSourceFile := fmt.Sprintf("%s/%s-cross.tgz", sourcesPath, device.TargetTriple())
	ensure.Success(
		ensure.Target(toolchainSourceFile,
			ensure.Cmd(
				"wget", "-nc",
				fmt.Sprintf("https://musl.cc/%s", filepath.Base(toolchainSourceFile)),
				"-O", toolchainSourceFile)),
		"failed to download source toolchain")

	ensure.Success(
		ensure.Target(fmt.Sprintf("%s/bin/%s-gcc", toolchainPath, device.TargetTriple()),
			ensure.Cmd("tar", "-xmf", toolchainSourceFile, "-C", toolchainPath, "--strip-components=1")),
		"failed to extract toolchain")

	var components []External
	ensure.Success(
		filepath.Walk(filepath.Join(projectPath, "external"),
			func(path string, info fs.FileInfo, err error) error {
				if err != nil || info.IsDir() || filepath.Base(path) != "build.json" {
					return err
				}
				ext, err := LoadExternal(path)
				if err != nil {
					return fmt.Errorf("%v: %v", path, err)
				}
				components = append(components, ext)
				return nil
			}), "failed to load external components")

	kernelImage := filepath.Join(imagesPath, "kernel.img")
	ensure.Success(func() error {
		ext, err := Sort(components, []string{
			kernelImage,
		})
		if err != nil {
			return err
		}
		components = ext
		return nil
	}(), "failed to sort components")

	for _, c := range components {
		ensure.Success(
			ensure.Target(c.Provides, c.Build, c.Depends...),
			"failed to build external component")
	}

	for _, dir := range []string{"cmd", "service", "apps"} {
		pkgs, err := os.ReadDir(filepath.Join(projectPath, dir))
		if err != nil {
			continue
		}

		for _, pkg := range pkgs {
			target := filepath.Join(systemPath, dir, pkg.Name())
			if _, err := os.Stat(filepath.Join(projectPath, dir, "cgo.go")); err == nil {
				os.Setenv("CGO_ENABLED", "1")
			} else {
				os.Setenv("CGO_ENABLED", "0")
			}
			ensure.Success(
				ensure.Target(target,
					ensure.Cmd("go", "build", "-o", target, fmt.Sprintf("rlxos.dev/%s/%s", dir, pkg.Name()))),
				"failed to build rlxos.dev/%s/%s", dir, pkg.Name())
		}
	}

	systemImage := filepath.Join(imagesPath, "system.img")
	ensure.Success(
		ensure.Target(systemImage,
			func() error {
				for _, dir := range []string{"config", "data"} {
					err := ensure.Cmd("rsync", "-a", "--delete", filepath.Join(projectPath, dir)+"/", filepath.Join(systemPath, dir)+"/")()
					if err != nil {
						return err
					}
				}
				ensure.Cmd("go", "run", "rlxos.dev/cmd/module", "-root", systemPath, "-kernel", kernelVersion, "cache")()
				return ensure.Cmd("mksquashfs", systemPath, systemImage, "-noappend", "-all-root")()
			}),
		"failed to build system image")

	initramfsImage := filepath.Join(imagesPath, "initramfs.img")
	ensure.Success(
		ensure.Target(initramfsImage,
			func() error {
				ensure.Cmd("install", "-v", "-D", "-m0755", filepath.Join(systemPath, "cmd", "init"), filepath.Join(initramfsPath, "init"))()
				return ensure.Cmd(
					"sh", "-e", "-c", "cd "+initramfsPath+" && find . -print0 | cpio --null -ov --format=newc --quiet 2>/dev/null >"+initramfsImage)()
			}),
		"failed to build initramfs image")

	if runTest {
		args := []string{
			"-smp", fmt.Sprint(cpu),
			"-m", fmt.Sprintf("%dM", memory),
			"-kernel", kernelImage,
			"-initrd", initramfsImage,
			"-drive", "file=" + systemImage + ",format=raw",
			"-append", "-rootfs /dev/sda console=tty0 console=ttyS0",
		}
		args = append(args, device.Emulation...)

		if debug {
			args = append(args, "-serial", "tcp::5555,server")
		}

		if _, err := os.Stat("/dev/kvm"); err == nil {
			args = append(args, "-enable-kvm")
		}

		if vnc >= 0 {
			args = append(args, "-vnc", fmt.Sprintf(":%d", vnc))
		}

		ensure.Cmd("qemu-system-"+device.ArchAlias(), args...)()
	}
}

func prepareDirectories() error {
	if cachePath == "" {
		cachePath = filepath.Join(projectPath, "_cache")
	}

	if devicePath == "" {
		return fmt.Errorf("no device path specified")
	} else if devicePath[0] != '/' {
		devicePath = filepath.Join(projectPath, "devices", devicePath)
	}

	if err := LoadDeviceConfig(filepath.Join(devicePath, "config.json")); err != nil {
		return fmt.Errorf("LoadDeviceConfig: %v", err)
	}

	deviceCachePath = filepath.Join(cachePath, device.Name)
	toolchainPath = filepath.Join(deviceCachePath, "toolchain")
	systemPath = filepath.Join(deviceCachePath, "system")
	initramfsPath = filepath.Join(deviceCachePath, "initramfs")
	kernelPath = filepath.Join(deviceCachePath, "kernel")
	imagesPath = filepath.Join(deviceCachePath, "images")
	buildPath = filepath.Join(deviceCachePath, "build")
	sourcesPath = filepath.Join(cachePath, "sources")

	sysrootPath = filepath.Join(toolchainPath, device.TargetTriple())

	if clean {
		log.Println("cleaning build")
		for _, dir := range []string{
			systemPath,
			initramfsPath,
			imagesPath,
		} {
			os.RemoveAll(dir)
		}
	}

	for _, p := range []string{
		deviceCachePath, toolchainPath, systemPath,
		initramfsPath, kernelPath, imagesPath, buildPath,
		sourcesPath,
	} {
		ensure.Success(os.MkdirAll(p, 0755), "failed to create %v", p)
	}

	return nil
}

func checkup() error {
	var missing []string
	for _, bin := range []string{
		"go", "rsync", "wget", "mksquashfs", "flex",
		"bison", "bc", "cpio", "make",
	} {
		if _, err := exec.LookPath(bin); err != nil {
			missing = append(missing, bin)
		}
	}

	for _, header := range []string{
		"gelf.h",
		"openssl/ssl.h",
	} {
		if _, err := os.Stat(filepath.Join("/usr/include", header)); err != nil {
			missing = append(missing, header)
		}
	}
	if missing != nil {
		return fmt.Errorf("missing %v", missing)
	}
	return nil
}
