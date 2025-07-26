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
	"io"
	"os"
)

func cat(args []string) error {
	var in *os.File
	if len(args) == 0 {
		in = os.Stdin
	} else {
		var err error
		in, err = os.OpenFile(args[0], os.O_RDONLY, 0)
		if err != nil {
			return err
		}
	}

	io.Copy(os.Stdout, in)

	if in != os.Stdin {
		in.Close()
	}
	return nil
}
