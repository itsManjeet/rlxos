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
	"path/filepath"
	"strings"
)

func main() {
	flag.Parse()

	if flag.NArg() == 0 {
		flag.Usage()
		return
	}

	for _, arg := range flag.Args() {
		if err := act(arg); err != nil {
			log.Fatal(err)
		}
	}
}

func act(c string) error {
	var p string
	if i := strings.Index(c, "="); i != -1 {
		v := c[i+1:]
		c = c[:i]
		p = configToPath(c)

		if err := os.WriteFile(p, []byte(v), 0); err != nil {
			return fmt.Errorf("failed to write %v=%v: %v", c, v, err)
		}
	} else {
		p = configToPath(c)
	}

	v, err := os.ReadFile(p)
	if err != nil {
		return fmt.Errorf("failed to read %v: %v", c, err)
	}
	fmt.Printf("%v=%v", c, string(v))
	return nil
}

func configToPath(c string) string {
	return filepath.Join("/proc/sys", strings.ReplaceAll(c, ".", "/"))
}
