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
	"image"
	"log"
	"os/exec"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/app"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/kernel/vt"
)

type Console struct {
	graphics.Label

	vt         *vt.VT
	rows, cols int
}

func (c *Console) Init(rect image.Rectangle) error {
	var err error

	c.vt, err = vt.Open()
	if err != nil {
		return err
	}
	if err = c.vt.Start(exec.Command("shell")); err != nil {
		return fmt.Errorf("failed to start shell %v", err)
	}

	_ = app.Backend().Listen(&EventProvider{
		vt: c.vt,
	})

	c.Label = graphics.Label{
		HorizontalAlignment: graphics.StartAlignment,
		VerticalAlignment:   graphics.StartAlignment,
		ForegroundColor:     argb.NewColor(255, 255, 255, 255),
		Size:                8,
	}
	c.SetBounds(rect)
	return nil
}

func (c *Console) SetBounds(rect image.Rectangle) {
	if rect.Dx() == c.Bounds().Dx() && rect.Dy() == c.Bounds().Dy() {
		c.BaseWidget.SetBounds(rect)
		return
	}
	c.BaseWidget.SetBounds(rect)

	chWidth, chHeight := graphics.FontSize(c.Label.Size)
	c.cols = rect.Dx() / chWidth
	c.rows = rect.Dy() / chHeight
	log.Println("Setting size:", c.cols, c.rows)
	_ = c.vt.Resize(uint16(c.cols), uint16(c.rows))
}

func (c *Console) Update(ev event.Event) {
	switch ev := ev.(type) {
	case VTEvent:
		log.Println("Got pty event:", string(ev))
		c.Text += string(ev)
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
}

func main() {
	if err := app.Run(&Console{}); err != nil {
		log.Fatal(err)
	}
}
