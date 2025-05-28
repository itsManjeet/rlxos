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
	"net"
	"os"
)

var (
	addr     string
	conn     net.Conn
	commands = map[string]func([]string) error{
		"shell": shell,
	}
)

func init() {
	flag.StringVar(&addr, "addr", "0.0.0.0:5555", "the address to connect to")
}

func main() {
	var err error

	flag.Parse()
	if flag.NArg() == 0 {
		flag.Usage()
		os.Exit(0)
	}

	cmd, ok := commands[flag.Arg(0)]
	if !ok {
		fmt.Printf("unknown command: %s\n", flag.Arg(0))
		os.Exit(1)
	}

	conn, err = net.Dial("tcp", addr)
	if err != nil {
		log.Fatal(err)
	}
	defer conn.Close()

	log.Printf("connected to %s", addr)

	if err := cmd(flag.Args()[1:]); err != nil {
		log.Fatal(err)
	}
}
