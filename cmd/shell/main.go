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
	"log"
	"net"

	"rlxos.dev/api/shell"
	"rlxos.dev/pkg/connect"
)

var (
	commands = map[string]func([]string) error{
		"add-window":    addWindow,
		"remove-window": removeWindow,
	}

	conn *connect.Connection
)

func init() {

}

func main() {
	flag.Parse()
	if flag.NArg() == 0 {
		flag.Usage()
		return
	}

	cmd, ok := commands[flag.Arg(0)]
	if !ok {
		log.Fatal("invalid command: ", flag.Arg(0))
	}

	c, err := net.Dial("unix", shell.SOCKET_PATH)
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()

	conn = connect.NewConnection(c, nil)

	if err := cmd(flag.Args()[1:]); err != nil {
		log.Fatal(err)
	}
}
