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
	"os/exec"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics/app"
	"rlxos.dev/pkg/graphics/widget"
	"rlxos.dev/pkg/kernel/vt"
)

type Console struct {
	widget.Base

	fontSize   int
	vt         *vt.VT
	rows, cols int
}

func (c *Console) Construct() {
	var err error

	c.vt, err = vt.Open()
	if err != nil {
		log.Fatalf("ERROR: %v", err)
	}
	if err = c.vt.Start(exec.Command("shell")); err != nil {
		log.Fatalf("failed to start shell %v", err)
	}

	_ = app.Backend().Listen(&EventProvider{
		vt: c.vt,
	})

	c.fontSize = 8
}

func (c *Console) SetBounds(rect image.Rectangle) {
	if rect.Dx() == c.Bounds().Dx() && rect.Dy() == c.Bounds().Dy() {
		c.Base.SetBounds(rect)
		return
	}
	c.Base.SetBounds(rect)

	chWidth, chHeight := 8, 8
	c.cols = rect.Dx() / chWidth
	c.rows = rect.Dy() / chHeight
	log.Println("Setting size:", c.cols, c.rows)
	_ = c.vt.Resize(uint16(c.cols), uint16(c.rows))
}

func (c *Console) Update(ev event.Event) bool {
	switch ev := ev.(type) {
	case VTEvent:
		log.Println("Got pty event:", string(ev))
		c.SetDirty(true)

	case key.Event:
		if ev.State == key.Pressed {
			if r, ok := key.ToAscii[ev.Key]; ok {
				_, _ = c.vt.Write([]byte{byte(r)})
			} else {
				switch ev.Key {
				case key.KEY_ENTER:
					_, _ = c.vt.Write([]byte{'\r'})
				case key.KEY_TAB:
					_, _ = c.vt.Write([]byte{'\t'})
				case key.KEY_BACKSPACE:
					_, _ = c.vt.Write([]byte{127})
				case key.KEY_ESC:
					_, _ = c.vt.Write([]byte{27})
				case key.KEY_SPACE:
					_, _ = c.vt.Write([]byte{' '})
				}
			}
		}
	}
	return true
}

func main() {
	if err := app.Run(&Console{}); err != nil {
		log.Fatal(err)
	}
}
