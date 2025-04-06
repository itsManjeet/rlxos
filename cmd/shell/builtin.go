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
	"os"
	"strings"
)

var builtins = map[string]func(args []string) error{
	"cd":     cd,
	"exit":   exit,
	"export": export,
}

func export(args []string) error {
	if len(args) != 1 {
		return fmt.Errorf("shell: expect arguments to 'export'")
	}
	key := args[0]
	var value string
	if idx := strings.Index(key, "="); idx != -1 {
		value = key[idx+1:]
		key = key[:idx]
	}

	return os.Setenv(key, value)
}

func cd(args []string) error {
	if len(args) != 1 {
		return fmt.Errorf("shell: expect argument to 'cd'")
	}
	return os.Chdir(args[0])
}

func exit(args []string) error {
	os.Exit(0)
	return nil
}
