/*
 * Copyright (c) 2025 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"

	"rlxos.dev/tools/ignite/ensure"
)

const (
	TOOLCHAIN_VERSION = "2025.02"
	TOOLCHAIN_URL     = "https://buildroot.org/downloads/buildroot-%s.tar.xz"
)

var (
	projectPath     string
	cachePath       string
	toolchainSource = fmt.Sprintf(TOOLCHAIN_URL, TOOLCHAIN_VERSION)
	clean           bool
	toolchainPath   string
	devicePath      string
	buildPath       string
	sourcesPath     string
	deviceCachePath string
	targetPath      string
	hostPath        string
	sysrootPath     string
	outputPath      string
	device          Device
	defconfig       string
	environ         []string
)

func init() {
	cur, _ := os.Getwd()
	flag.StringVar(&projectPath, "project-path", cur, "project path")
	flag.StringVar(&cachePath, "cache-path", "", "cache path")
	flag.StringVar(&devicePath, "device", "", "device config path")
	flag.StringVar(&toolchainSource, "source-url", toolchainSource, "toolchain source url")
	flag.BoolVar(&clean, "clean", false, "clean toolchain")
}

func main() {
	ensure.Success(parseArgs())

	log.Println("Ensuring toolchain")
	toolchainStamp := filepath.Join(deviceCachePath, ".stamp_toolchain_built")
	toolchainSourceFile := filepath.Join(sourcesPath, filepath.Base(toolchainSource))
	configPath := filepath.Join(deviceCachePath, ".config")
	ensure.Path(cachePath, sourcesPath, toolchainPath, deviceCachePath)
	ensure.Command(toolchainSourceFile, &exec.Cmd{Args: []string{"curl", "-C", "-", "-o", toolchainSourceFile, toolchainSource}})
	ensure.Command(filepath.Join(toolchainPath, "Makefile"), &exec.Cmd{Args: []string{"tar", "-xf", toolchainSourceFile, "-C", toolchainPath, "--strip-components=1"}})

	if clean {
		targetPath = filepath.Join(deviceCachePath, "target")
		for _, dir := range []string{
			targetPath,
			filepath.Join(buildPath, "skeleton"),
			filepath.Join(buildPath, "skeleton-custom"),
			filepath.Join(buildPath, "skeleton-init-common"),
			filepath.Join(buildPath, "skeleton-init-none"),
		} {
			if err := os.RemoveAll(dir); err != nil {
				log.Fatal(err)
			}
		}

		for _, file := range []string{
			toolchainStamp,
			configPath,
		} {
			if err := os.Remove(file); err != nil && !os.IsNotExist(err) {
				log.Fatal(err)
			}
		}

		log.Println("Removing installation time stamps")
		buildDir := filepath.Join(deviceCachePath, "build")
		_ = os.MkdirAll(buildDir, 0755)
		ensure.ForeachIn(buildDir, func(path string, info os.FileInfo) error {
			_ = os.Remove(filepath.Join(path, ".stamp_target_installed"))
			if strings.HasPrefix(filepath.Base(path), "host-gcc-final") {
				_ = os.Remove(filepath.Join(path, ".stamp_host_installed"))
			}
			return nil
		})
	}

	ensure.Target(configPath, func() error {
		options := slices.Clone(toolchainOptions)

		// Arch options
		options = append(options, fmt.Sprintf("BR2_%s=y", device.Arch))

		// graphics options
		for _, driver := range device.Graphics.Drivers {
			options = append(options, fmt.Sprintf("BR2_PACKAGE_MESA3D_GALLIUM_DRIVER_%s=y", strings.ToUpper(driver)))
		}

		// extra options
		options = append(options, device.Extra...)

		{
			file, err := os.OpenFile(defconfig, os.O_RDWR|os.O_CREATE, 0644)
			if err != nil {
				return err
			}
			defer file.Close()

			if _, err = file.WriteString(strings.Join(options, "\n")); err != nil {
				return err
			}
		}

		toolchain("defconfig")

		return nil
	})

	ensure.Target(filepath.Join(hostPath, "bin", "go"), func() error {
		toolchain("host-go")
		return nil
	})

	ensure.Target(toolchainStamp, func() error {
		toolchain(flag.Args()...)
		return os.WriteFile(toolchainStamp, []byte("DONE"), 0644)
	})

	ensure.Target(filepath.Join(outputPath, fmt.Sprintf("%s_sdk-buildroot.tar.gz", device.TargetTriple)), func() error {
		toolchain("sdk")
		return nil
	})

	ensure.Success(prepareRootfs())

	for _, script := range []string{
		"mkinitramfs.sh",
		"mksquashfs.sh",
		"genimage.sh",
	} {
		ensure.Command("", &exec.Cmd{
			Args: []string{"sh", "-e", filepath.Join(projectPath, "tools/ignite/scripts", script)},
			Dir:  projectPath,
			Env:  environ,
		})
	}
}

func parseArgs() error {
	flag.Parse()

	if cachePath == "" {
		cachePath = filepath.Join(projectPath, "_cache")
	}

	if devicePath == "" {
		return fmt.Errorf("no device config path specified")
	}

	if err := device.LoadConfig(filepath.Join(projectPath, "devices", devicePath, "config.json")); err != nil {
		return err
	}

	toolchainPath = filepath.Join(cachePath, "toolchain")
	sourcesPath = filepath.Join(cachePath, "sources")
	deviceCachePath = filepath.Join(cachePath, device.ID)
	targetPath = filepath.Join(deviceCachePath, "target")
	hostPath = filepath.Join(deviceCachePath, "host")
	sysrootPath = filepath.Join(hostPath, device.TargetTriple, "sysroot")
	outputPath = filepath.Join(deviceCachePath, "images")
	defconfig = filepath.Join(deviceCachePath, "defconfig")
	buildPath = filepath.Join(deviceCachePath, "build")

	environ = append(os.Environ(),
		"PATH="+filepath.Join(hostPath, "bin")+":"+os.Getenv("PATH"),
		"INSIDE_IGNITE=1",
		"TARGET_DIR="+targetPath,
		"HOST_DIR="+hostPath,
		"OUTPUT_DIR="+outputPath,
		"SYSROOT_DIR="+sysrootPath,
		"CACHE_DIR="+cachePath,
		"TOOLCHAIN_DIR="+toolchainPath,
		"PROJECT_DIR="+projectPath,
		"DEVICE_DIR="+devicePath,
		"DEVICE_CACHE_DIR="+deviceCachePath,
		"CGO_CFLAGS=--sysroot="+sysrootPath,
		"CGO_LDFLAGS=--sysroot="+sysrootPath,
		"GOROOT="+hostPath+"/lib/go",
		"CC="+device.TargetTriple+"-gcc",
		"CXX="+device.TargetTriple+"-g++",
		"LD="+device.TargetTriple+"-ld",
	)

	return nil
}
