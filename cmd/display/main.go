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
	"image"
	"log"
	"net"

	"rlxos.dev/api/display"
	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/kernel/shm"
)

func main() {
	c, err := net.Dial("unix", display.SOCKET_PATH)
	if err != nil {
		log.Fatal(err)
	}
	defer c.Close()

	conn := connect.NewConnection(c, nil)

	img, err := shm.NewImage(100, 100)
	if err != nil {
		log.Fatal(err)
	}
	defer img.Destroy()

	graphics.Clear(img, graphics.White)
	graphics.FillRect(img, image.Rect(0, 0, 50, 50), 10, argb.NewColor(255, 0, 255, 255))

	var reply display.UploadReply
	if err := conn.Call("Upload", display.UploadArgsFromImage(img, image.Pt(0, 0)), &reply); err != nil {
		log.Fatal(err)
	}
	if err := conn.Call("Sync", display.SyncArgs{}, &display.SizeReply{}); err != nil {
		log.Fatal(err)
	}
}
