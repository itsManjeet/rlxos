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

func export(args []string) error {
	for _, a := range args {
		idx := strings.Index(a, "=")
		if idx == -1 {
			return fmt.Errorf("failed to export %v, no value specified", a)
		}
		if err := os.Setenv(a[:idx], a[idx+1:]); err != nil {
			return err
		}
	}
	return nil
}
