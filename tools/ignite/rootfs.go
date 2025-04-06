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

	"rlxos.dev/tools/ignite/ensure"
)

func prepareRootfs() error {
	for _, kind := range []string{"cmd", "apps", "service"} {
		ensure.ForeachIn(filepath.Join(projectPath, kind), func(path string, info os.FileInfo) error {
			return buildModule(path)
		})
	}
	return nil
}

func buildModule(path string) error {
	moduleID := strings.TrimPrefix(path, projectPath)
	configureScript := filepath.Join(path, "configure")

	ensure.IfExists(configureScript, func() error {
		ensure.Command("", &exec.Cmd{
			Args: []string{"sh", "-e", configureScript},
			Dir:  path,
			Env:  environ,
		})
		return nil
	})

	cgoEnv := "CGO_ENABLED=0"
	ensure.IfExists(path+"/cgo.go", func() error {
		cgoEnv = "CGO_ENABLED=1"
		return nil
	})

	ensure.Command("", &exec.Cmd{
		Args: []string{filepath.Join(hostPath, "bin", "go"), "build", "-o", targetPath + "/" + moduleID, "rlxos.dev/" + moduleID},
		Dir:  path,
		Env:  append(environ, cgoEnv),
	})
	return nil
}
