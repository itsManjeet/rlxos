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
	"log"
	"net"
	"time"

	"rlxos.dev/api/display"
	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/kernel/input"
	"rlxos.dev/service/shell/window"
)

func main() {
	ip, err := input.NewManager()
	if err != nil {
		log.Fatal(err)
	}
	defer ip.Close()
	if err := ip.RegisterAll("/dev/input/event*"); err != nil {
		log.Fatal(err)
	}

	c, err := net.Dial("unix", display.SOCKET_PATH)
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()

	server := &Server{
		input: ip,
	}
	conn := connect.NewConnection(c, server)
	server.display = conn
	var size display.SizeReply
	if err := conn.Call("Size", display.SizeArgs{}, &size); err != nil {
		log.Fatal(err)
	}
	server.background, err = LoadBackground(size.Width, size.Height)
	if err != nil {
		log.Fatal(err)
	}
	defer server.background.Destroy()

	server.panel, err = NewPanel(size.Width, size.Height)
	if err != nil {
		log.Fatal(err)
	}

	win, _ := window.NewWindow(0, 0, 100, 100)
	server.windows = append(server.windows, win)

	for {
		server.update()
		server.render()

		time.Sleep(time.Millisecond * 16)
	}
}
