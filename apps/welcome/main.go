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
	"log"
	"net"
	"time"

	"rlxos.dev/api/shell"
	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/kernel/shm"
)

func main() {
	c, err := net.Dial("unix", shell.SOCKET_PATH)
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()

	conn := connect.NewConnection(c, nil)

	var reply shell.AddWindowReply
	if err := conn.Call("AddWindow", &shell.AddWindowArgs{
		Width:  600,
		Height: 400,
	}, &reply); err != nil {
		log.Fatal(err)
	}
	defer conn.Call("RemoveWindow", &shell.RemoveWindowArgs{
		Key: reply.Key,
	}, &shell.RemoveWindowReply{})

	dst, err := shm.NewImageForKey(reply.Key, 600, 400)
	if err != nil {
		log.Fatal(err)
	}

	frameCount := 0
	startTime := time.Now()
	fps := 0.0
	for {
		if elapsed := time.Since(startTime); elapsed >= time.Second {
			frameCount = 0
			fps = float64(frameCount) / elapsed.Seconds()
			startTime = time.Now()
		}

		graphics.Clear(dst, argb.NewColor(255, 255, 0, 255))
		graphics.Text(dst, dst.Bounds(), fmt.Sprintf("FPS: %.2f", fps), 8, argb.NewColor(0, 0, 0, 255))

		time.Sleep(time.Millisecond * 16)
	}
}
