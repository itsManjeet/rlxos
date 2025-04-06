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
	"fmt"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"syscall"
)

var (
	root       string
	rootfsType string
	live       bool
)

func startRescueShell() {
	cmd := exec.Command("shell")
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	if err := cmd.Run(); err != nil {
		log.Fatal("failed to start rescue shell", err)
	}
}

func isInsideInitrd() bool {
	return os.Args[0] == "/init"
}

func switchToRealRoot() error {
	var errors []string
	safeCall := func(call string, err error) {
		if err != nil {
			errors = append(errors, call+": "+err.Error())
		}
	}

	syscall.Umask(0)
	safeCall("setenv", os.Setenv("PATH", "/cmd:/usr/bin:/usr/sbin"))

	log.Println("preparing pseudo filesystem")

	safeCall("mount(proc)", syscall.Mount("proc", "/proc", "proc", syscall.MS_NOSUID|syscall.MS_NODEV|syscall.MS_NOEXEC, ""))
	safeCall("mount(sysfs)", syscall.Mount("sysfs", "/sys", "sysfs", syscall.MS_NOSUID|syscall.MS_NODEV|syscall.MS_NOEXEC, ""))
	safeCall("mount(devtmpfs)", syscall.Mount("devtmpfs", "/dev", "devtmpfs", syscall.MS_NOSUID, "mode=0755"))
	safeCall("mount(tmpfs)", syscall.Mount("tmpfs", "/run", "tmpfs", syscall.MS_NOSUID|syscall.MS_NODEV, "mode=0755"))

	safeCall("mkdir(dev/shm)", syscall.Mkdir("/dev/shm", 0755))
	safeCall("mount(shm)", syscall.Mount("tmpfs", "/dev/shm", "tmpfs", syscall.MS_NOSUID|syscall.MS_NODEV, "mode=1777"))

	safeCall("mkdir(dev/pts)", syscall.Mkdir("/dev/pts", 0755))
	safeCall("mount(devpts)", syscall.Mount("devpts", "/dev/pts", "devpts", 0, ""))

	safeCall("/proc/cmdline", parseCmdline())

	kmsg, err := os.OpenFile("/dev/kmsg", os.O_RDWR, 0)
	if err == nil {
		log.SetOutput(kmsg)
	}
	defer func() {
		if kmsg != nil {
			kmsg.Close()
		}
	}()

	if errors != nil {
		fmt.Println(strings.Join(errors, "\n"))
		log.Fatal("INIT failed to prepare pseudo filesystem")
	}
	errors = nil

	safeCall("modprobe", loadKernelModules())

	switch {
	case strings.HasPrefix(root, "LABEL="):
		root = filepath.Join("/dev/disk/by-label", strings.TrimPrefix(root, "LABEL="))
	case strings.HasPrefix(root, "UUID="):
		root = filepath.Join("/dev/disk/by-uuid", strings.TrimPrefix(root, "UUID="))
	case root == "":
		log.Fatal("no root device specified")
	}

	sysroot := "/sysroot"
	livePath := "/run/live"
	rootPath := "/run/root"
	var systemImage string

	log.Println("ensuring hierarchy")
	for _, dir := range []string{sysroot, livePath, rootPath} {
		if err := os.MkdirAll(dir, 0755); err != nil {
			log.Fatal("failed to create required path", dir, err)
		}
	}

	for _, dir := range []string{"rw", "ro", "work"} {
		dir = filepath.Join(livePath, dir)
		if err := os.MkdirAll(dir, 0755); err != nil {
			log.Fatal("failed to create required path", dir, err)
		}
	}

	if live {
		log.Println("setting up live boot")
		rootPath = "/run/iso"
		if err := os.MkdirAll(rootPath, 0755); err != nil {
			log.Fatal("failed to create required path", rootPath, err)
		}
		systemImage = filepath.Join(rootPath, "rootfs.sfs")
	} else {
		rootPath = filepath.Join(livePath, "ro")
	}

	if _, err := os.Stat(root); err != nil {
		log.Println("no root device found at", root)
		startRescueShell()
	}

	log.Println("mounting real filesystem")
	safeCall("mount(root)", syscall.Mount(root, rootPath, rootfsType, syscall.MS_RDONLY, ""))
	if live {
		safeCall("mount(system)", exec.Command("busybox", "mount", systemImage, filepath.Join(livePath, "ro")).Run())
	}

	safeCall("mount(overlay)", syscall.Mount("overlay", sysroot, "overlay", 0, fmt.Sprintf("lowerdir=%s/ro,upperdir=%s/rw,workdir=%s/work", livePath, livePath, livePath)))

	if errors != nil {
		fmt.Println(strings.Join(errors, "\n"))
		startRescueShell()
	}

	log.Println("switching to real filesystem")
	safeCall("mount(proc)", syscall.Mount("/proc", "/sysroot/proc", "", syscall.MS_MOVE, ""))
	safeCall("mount(sysfs)", syscall.Mount("/sys", "/sysroot/sys", "", syscall.MS_MOVE, ""))
	safeCall("mount(devtmpfs)", syscall.Mount("/dev", "/sysroot/dev", "", syscall.MS_MOVE, ""))
	safeCall("mount(tmpfs)", syscall.Mount("/run", "/sysroot/run", "", syscall.MS_MOVE, ""))

	safeCall("chdir(/sysroot)", os.Chdir("/sysroot"))
	safeCall("mount(/sysroot)", syscall.Mount("/sysroot", "/", "", syscall.MS_MOVE, ""))
	safeCall("chroot(/sysroot)", syscall.Chroot("."))

	if errors != nil {
		fmt.Println(strings.Join(errors, "\n"))
		log.Fatal("INIT failed to prepare switch root")
	}

	log.Println("starting real init")
	return syscall.Exec("/cmd/init", []string{"/cmd/init", "rootfs"}, os.Environ())
}

func parseCmdline() error {
	cmdline, err := os.ReadFile("/proc/cmdline")
	if err != nil {
		return err
	}

	for _, arg := range strings.Fields(string(cmdline)) {
		if idx := strings.Index(arg, "="); idx != -1 {
			switch value := arg[idx+1:]; arg[:idx] {
			case "root":
				root = value
			case "rootfs-type":
				rootfsType = value
			}
		} else if arg == "live" {
			live = true
		}
	}

	return nil
}

func loadKernelModules() error {
	filepath.WalkDir("/sys", func(path string, d fs.DirEntry, err error) error {
		if err != nil || filepath.Base(path) != "modalias" {
			return err
		}
		data, err := os.ReadFile(path)
		if err != nil {
			return nil
		}
		for _, line := range strings.Split(string(data), "\n") {
			line = strings.TrimSpace(line)
			if line == "" {
				continue
			}
			if _, err := exec.Command("modprobe", "-b", "-a", line).CombinedOutput(); err != nil {
				continue
			}
		}
		return nil
	})
	return nil
}
