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
	"os"

	"rlxos.dev/api/display"
	"rlxos.dev/pkg/connect"
)

var (
	card string
)

func init() {
	flag.StringVar(&card, "card", "/dev/dri/card0", "Graphics Card")
	log.SetOutput(os.Stderr)

	_ = os.Remove(display.SOCKET_PATH)
}

func main() {
	flag.Parse()

	l, err := net.Listen("unix", display.SOCKET_PATH)
	if err != nil {
		log.Fatal(err)
	}
	defer l.Close()

	d, err := OpenDisplay(card)
	if err != nil {
		log.Fatal(err)
	}
	defer d.Close()

	for {
		conn, err := l.Accept()
		if err != nil {
			continue
		}

		connect.NewConnection(conn, &Server{display: d})
	}

}
