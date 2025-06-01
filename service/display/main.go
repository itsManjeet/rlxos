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
	"image"
	"image/draw"
	"log"
	"os"
	"time"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/kernel/input"
)

var (
	card string
)

func init() {
	flag.StringVar(&card, "card", "/dev/dri/card0", "Graphics Card")
	log.SetOutput(os.Stderr)
}

func main() {
	flag.Parse()

	d, err := OpenDisplay(card)
	if err != nil {
		log.Fatal(err)
	}
	defer d.Close()

	ip, err := input.NewManager()
	if err != nil {
		log.Fatal(err)
	}
	defer ip.Close()

	if err := ip.RegisterAll("/dev/input/event*"); err != nil {
		log.Fatal(err)
	}

	var cursor image.Point
	keys := map[int]bool{}

	var canvas draw.Image

	for {
		clear(keys)

		events, err := ip.PollEvents()
		if err == nil {
			for _, ev := range events {
				switch ev := ev.(type) {
				case input.CursorEvent:
					log.Println("CURSOR EVENT:", ev)
					if ev.Absolute {
						if ev.X != 0 {
							cursor.X = ev.X
						}
						if ev.Y != 0 {
							cursor.Y = ev.Y
						}
					} else {
						cursor.X += ev.X
						cursor.Y += ev.Y
					}

				case input.KeyEvent:
					keys[ev.Code] = ev.Pressed
				}
			}
		}

		canvas = d.Canvas()

		graphics.Clear(canvas, graphics.Black)
		graphics.Text(canvas, canvas.Bounds(), "Welcome To RLXOS", 12, graphics.White)

		graphics.Dot(canvas, cursor, graphics.White, 4)

		time.Sleep(time.Millisecond * 16)

		d.Sync()
	}

}
