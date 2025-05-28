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
	"bufio"
	"flag"
	"fmt"
	"os"
	"regexp"
)

var (
	packageID string
)

func init() {
	flag.StringVar(&packageID, "package", "main", "Package ID")
}

func main() {
	flag.Parse()

	if flag.NArg() != 2 {
		return
	}

	input := flag.Arg(0)
	outFile := flag.Arg(1)

	file, err := os.Open(input)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	out, err := os.Create(outFile)
	if err != nil {
		panic(err)
	}
	defer out.Close()

	fmt.Fprintf(out, "package %s\n\n", packageID)
	fmt.Fprintln(out, "const (")

	re := regexp.MustCompile(`^#define\s+(KEY_[A-Z0-9_]+)\s+(0x[0-9a-fA-F]+|\d+)`)

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		if matches := re.FindStringSubmatch(line); matches != nil {
			fmt.Fprintf(out, "    %s = %s\n", matches[1], matches[2])
		}
	}

	fmt.Fprintln(out, ")")
}
