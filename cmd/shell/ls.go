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
	"os"
	"strings"
)

func ls(args []string) error {
	f := flag.NewFlagSet("ls", flag.ContinueOnError)

	showHidden := f.Bool("a", false, "show all hidden files")

	if err := f.Parse(args); err != nil {
		return err
	}

	args = f.Args()
	if len(args) == 0 {
		cwd, _ := os.Getwd()
		args = append(args, cwd)
	}

	for _, path := range args {
		dir, err := os.ReadDir(path)
		if err != nil {
			return err
		}
		s := ""
		for _, p := range dir {
			if strings.HasPrefix(p.Name(), ".") && !*showHidden {
				continue
			}
			v := s + p.Name()
			if p.IsDir() {
				v += "/"
			}
			fmt.Print(v)
			s = " "
		}
		fmt.Printf("\n")
	}
	return nil
}
