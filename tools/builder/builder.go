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
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

type Builder interface {
	Build(c Config, p string) error
}

type Meson struct {
}

func (m *Meson) Build(c Config, p string) error {
	toolchainfile := filepath.Join(cachePath, fmt.Sprintf("%s.meson.txt", target))
	if _, err := os.Stat(toolchainfile); err != nil {
		return fmt.Errorf("toolchain file %s not exists", toolchainfile)
	}

	buildDir := filepath.Join(p, "build")
	if err := run(p, "meson", "setup", "--cross-file", toolchainfile, "--prefix=/", buildDir); err != nil {
		return err
	}

	if err := run(p, "ninja", "-C", buildDir); err != nil {
		return err
	}

	if err := run(p, "ninja", "-C", buildDir, "install"); err != nil {
		return err
	}

	return nil
}

func run(d string, args ...string) error {
	log.Println(args)
	cmd := exec.Command(args[0], args[1:]...)

	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin
	cmd.Dir = d

	return cmd.Run()
}
