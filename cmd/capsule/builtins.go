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
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"rlxos.dev/pkg/capsule"
)

func registerBuiltins() {
	registerBusybox()
	registerShellCommands()
}

func registerBusybox() {
	output, err := exec.Command("busybox", "--list").CombinedOutput()
	if err != nil {
		return
	}
	for _, c := range strings.Fields(strings.Trim(string(output), "\n")) {
		capsule.Register(c, func(pallete []capsule.Capsule) (capsule.Capsule, error) {
			cmd := exec.Command("busybox", append([]string{c}, toStringList(pallete)...)...)
			cmd.Stdout = os.Stdout
			cmd.Stdin = os.Stdin
			cmd.Stderr = os.Stderr
			return cmd.Run(), nil
		})
	}
}

func registerShellCommands() {
	for _, path := range strings.Split(os.Getenv("PATH"), ":") {
		files, err := os.ReadDir(path)
		if err == nil {
			for _, bin := range files {
				if bin.IsDir() {
					continue
				}
				capsule.Register(bin.Name(), func(pallete []capsule.Capsule) (capsule.Capsule, error) {
					cmd := exec.Command(filepath.Join(path, bin.Name()), toStringList(pallete)...)
					cmd.Stdout = os.Stdout
					cmd.Stdin = os.Stdin
					cmd.Stderr = os.Stderr
					return cmd.Run(), nil
				})
			}
		}
	}
}

func toStringList(pallete []capsule.Capsule) []string {
	var s []string
	for _, p := range pallete {
		s = append(s, capsule.ToString(p))
	}
	return s
}
