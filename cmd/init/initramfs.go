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

	safeCall("mount(devtmpfs)", syscall.Mount("devtmpfs", "/dev", "devtmpfs", 0, ""))

	safeCall("mkdir(proc)", syscall.Mkdir("/proc", 0755))
	safeCall("mount(proc)", syscall.Mount("proc", "/proc", "proc", 0, ""))

	safeCall("mkdir(sysfs)", syscall.Mkdir("/sys", 0755))
	safeCall("mount(sysfs)", syscall.Mount("sysfs", "/sys", "sysfs", 0, ""))

	safeCall("mkdir(tmpfs)", syscall.Mkdir("/run", 0755))
	safeCall("mount(tmpfs)", syscall.Mount("tmpfs", "/run", "tmpfs", 0, ""))

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
	for _, dir := range []string{"/run/overlay", "/run/overlay/ro", "/run/overlay/rw", "/run/overlay/work", "/rootfs"} {
		safeCall("mkdir("+dir+")", syscall.Mkdir(dir, 0755))
	}
	safeCall("mount(rootfs)", syscall.Mount(rootfs, "/run/overlay/ro", "squashfs", syscall.MS_RDONLY, ""))
	safeCall("mount(overlay)", syscall.Mount("overlay", "/rootfs", "overlay", 0, "lowerdir=/run/overlay/ro,upperdir=/run/overlay/rw,workdir=/run/overlay/work"))
	ensureStage("prepare real rootfs")

	for _, fs := range []string{"proc", "sys", "dev", "run"} {
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
