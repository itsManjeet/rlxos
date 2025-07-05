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
	"strings"
	"syscall"

	"rlxos.dev/pkg/ensure"
)

var (
	errors []string
	rootfs string

	kernelFlags = flag.NewFlagSet("kernel", flag.ContinueOnError)
)

func isInsideInitramfs() bool {
	// TODO: check using /proc/mount for rootfs if mounted to tmpfs
	return os.Args[0] == "/init"
}

func ensureRealRootfs() {
	if !isInsideInitramfs() {
		return
	}

	safeCall("mount(devtmpfs)", syscall.Mount("devtmpfs", "/dev", "devtmpfs", syscall.MS_NOSUID, "mode=0755"))

	safeCall("mkdir(proc)", syscall.Mkdir("/proc", 0755))
	safeCall("mount(proc)", syscall.Mount("proc", "/proc", "proc", syscall.MS_NOSUID|syscall.MS_NOEXEC|syscall.MS_NODEV, ""))

	safeCall("mkdir(sysfs)", syscall.Mkdir("/sys", 0755))
	safeCall("mount(sysfs)", syscall.Mount("sysfs", "/sys", "sysfs", syscall.MS_NOSUID|syscall.MS_NOEXEC|syscall.MS_NODEV, ""))

	safeCall("mkdir(tmpfs)", syscall.Mkdir("/cache/temp", 0755))
	safeCall("mount(tmpfs)", syscall.Mount("tmpfs", "/cache/temp", "tmpfs", syscall.MS_NOSUID|syscall.MS_NODEV, "mode=0755"))

	safeCall("mkdir(devpts)", syscall.Mkdir("/dev/pts", 0755))
	safeCall("mount(devpts)", syscall.Mount("devpts", "/dev/pts", "devpts", syscall.MS_NOSUID|syscall.MS_NOEXEC, "mode=0620,gid=5"))

	safeCall("mkdir(shm)", syscall.Mkdir("/dev/shm", 0755))
	safeCall("mount(shm)", syscall.Mount("tmpfs", "/dev/shm", "tmpfs", syscall.MS_NOSUID|syscall.MS_NODEV, "mode=1777"))

	ensureStage("kernel pseudo filesystem mount")

	safeCall("parse(/proc/cmdline)", parseKernelFlags())
	ensureStage("parsing kernel args")

	if _, err := os.Stat(rootfs); err != nil {
		blocks, err := os.ReadDir("/sys/block")
		if err != nil {
			log.Fatal("failed to read /sys/block ", err)
		}
		for i, block := range blocks {
			log.Println(i, block.Name())
		}
		log.Fatal("no root device present ", rootfs)
	}
	for _, dir := range []string{"/cache/temp/overlay", "/cache/temp/overlay/ro", "/cache/temp/overlay/rw", "/cache/temp/overlay/work", "/rootfs"} {
		safeCall("mkdir("+dir+")", syscall.Mkdir(dir, 0755))
	}
	safeCall("mount(rootfs)", syscall.Mount(rootfs, "/cache/temp/overlay/ro", "squashfs", syscall.MS_RDONLY, ""))
	safeCall("mount(overlay)", syscall.Mount("overlay", "/rootfs", "overlay", 0, "lowerdir=/cache/temp/overlay/ro,upperdir=/cache/temp/overlay/rw,workdir=/cache/temp/overlay/work"))
	ensureStage("prepare real rootfs")

	for _, fs := range []string{"proc", "sys", "dev", "cache/temp"} {
		safeCall("mkdir("+fs+")", syscall.Mkdir("/rootfs/"+fs, 0755))
		safeCall("mount("+fs+")", syscall.Mount("/"+fs, "/rootfs/"+fs, "", syscall.MS_MOVE, ""))
	}

	safeCall("chdir(rootfs)", syscall.Chdir("/rootfs"))
	safeCall("chroot(rootfs)", syscall.Chroot("/rootfs"))
	ensureStage("switch to real rootfs")

	if err := syscall.Exec("/cmd/init", []string{"/cmd/init"}, []string{}); err != nil {
		log.Fatal(err)
	}
}

func safeCall(msg string, err error) {
	if err != nil {
		errors = append(errors, fmt.Sprintf("%s: %v", msg, err))
	}
}

func ensureStage(stage string) {
	if errors != nil {
		ensure.Foreach(errors, func(msg string) error {
			log.Println(msg)
			return nil
		})

		log.Fatal("failed to complete ", stage)
	}
}

func parseKernelFlags() error {
	data, err := os.ReadFile("/proc/cmdline")
	if err != nil {
		return fmt.Errorf("failed to read kernel cmdline flags %v", err)
	}

	kernelFlags.StringVar(&rootfs, "rootfs", "", "Specify rootfs")
	if err := kernelFlags.Parse(strings.Fields(string(data))); err != nil {
		return err
	}

	if rootfs == "" {
		return fmt.Errorf("no -rootfs specified")
	}

	return nil
}
