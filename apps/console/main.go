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
	"image/color"
	"log"
	"os/exec"
	"slices"
	"strconv"
	"strings"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/app"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/style"
	"rlxos.dev/pkg/graphics/widget"
	"rlxos.dev/pkg/kernel/vt"
)

type Console struct {
	widget.Base

	BackgroundColor color.Color

	fontSize   int
	cellSize   image.Point
	vt         *vt.VT
	rows, cols int
	cursor     image.Point
	buffer     [][]byte
	back       []byte
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
	c.cellSize = image.Point{
		X: 8,
		Y: 12,
	}
}

func (c *Console) OnStyleChange(s style.Style) {
	c.BackgroundColor = s.Background
	c.Base.OnStyleChange(s)
}

func (c *Console) SetBounds(rect image.Rectangle) {
	if rect.Dx() == c.Bounds().Dx() && rect.Dy() == c.Bounds().Dy() {
		c.Base.SetBounds(rect)
		return
	}
	c.Base.SetBounds(rect)

	c.cols = rect.Dx() / c.cellSize.X
	c.rows = rect.Dy() / c.cellSize.Y
	log.Println("Setting size:", c.cols, c.rows)
	_ = c.vt.Resize(uint16(c.cols), uint16(c.rows))

	c.buffer = make([][]byte, c.rows)
	for i := 0; i < c.rows; i++ {
		c.buffer[i] = make([]byte, c.cols)
	}
}

func (c *Console) Draw(cv canvas.Canvas) {
	graphics.FillRect(cv, c.Bounds(), 0, c.BackgroundColor)
	for y, row := range c.buffer {
		for x, ch := range row {
			pos := image.Point{
				X: x*c.cellSize.X + c.cellSize.X,
				Y: y*c.cellSize.Y + c.cellSize.Y,
			}
			if x == c.cursor.X && y == c.cursor.Y {
				graphics.Text(cv, pos, string(ch), c.fontSize, argb.NewColor(0, 0, 0, 255))
			} else {
				graphics.Text(cv, pos, string(ch), c.fontSize, argb.NewColor(255, 255, 255, 255))
			}
		}
	}
	c.Base.Draw(cv)
}

func (c *Console) Update(ev event.Event) bool {
	switch ev := ev.(type) {
	case VTEvent:
		if c.back != nil {
			ev = append(c.back, ev...)
			c.back = nil
		}

		log.Println("Got pty event:", string(ev))
		for i := 0; i < len(ev); i++ {
			ch := ev[i]

			switch ch {
			case 0x1b:
				if len(ev[i:]) < 2 || ev[i+1] != '[' {
					continue
				}
				idx := slices.IndexFunc(ev[i+2:], func(r byte) bool {
					return r >= '@' && r <= '~'
				})

				if idx == -1 {
					c.back = ev[i:]
					return true
				}

				c.processEscape(ev[i+2 : i+2+idx])
				i += 2 + idx

			case '\n':
				c.cursor.X = 0
				c.cursor.Y++
				if c.cursor.Y >= c.rows {
					c.scrollUp()
					c.cursor.Y = c.rows - 1
				}
			case '\r':
				c.cursor.X = 0
			case '\b':
				if c.cursor.X > 0 {
					c.cursor.X--
					c.buffer[c.cursor.Y][c.cursor.X] = ' '
				} else if c.cursor.Y > 0 {
					c.cursor.Y--
					c.cursor.X = c.cols - 1
					c.buffer[c.cursor.Y][c.cursor.X] = ' '
				}
			default:
				if ch >= 32 && ch < 127 {
					if c.cursor.Y < len(c.buffer) && c.cursor.X < len(c.buffer[c.cursor.Y]) {
						c.buffer[c.cursor.Y][c.cursor.X] = ch
					}
					c.cursor.X++
					if c.cursor.X >= c.cols {
						c.cursor.X = 0
						c.cursor.Y++
						if c.cursor.Y >= c.rows {
							c.scrollUp()
							c.cursor.Y = c.rows - 1
						}
					}
				}
			}
		}
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

func (c *Console) scrollUp() {
	copy(c.buffer[0:], c.buffer[1:])
	c.buffer[c.rows-1] = make([]byte, c.cols)
	for x := range c.buffer[c.rows-1] {
		c.buffer[c.rows-1][x] = ' '
	}
}

func (c *Console) processEscape(buf []byte) {
	if len(buf) == 0 {
		return
	}
	final := buf[len(buf)-1]
	params := string(buf[:len(buf)-1])
	args := strings.Split(params, ";")

	switch final {
	case 'J':
		if len(args) == 0 || args[0] == "2" {
			c.clearScreen()
		}
	case 'H':
		row, col := 0, 0
		if len(args) >= 1 && args[0] != "" {
			if v, err := strconv.Atoi(args[0]); err != nil {
				row = v - 1
			}
		}
		if len(args) >= 2 && args[1] != "" {
			if v, err := strconv.Atoi(args[1]); err == nil {
				col = v - 1
			}
		}
		c.moveCursor(row, col)
	}
}

func (c *Console) clearScreen() {
	for y := range c.buffer {
		for x := range c.buffer[y] {
			c.buffer[y][x] = ' '
		}
	}
	c.cursor = image.Point{}
}

func (c *Console) moveCursor(row, col int) {
	if row >= 0 && row < c.rows {
		c.cursor.Y = row
	}
	if col >= 0 && col < c.cols {
		c.cursor.X = col
	}
}

func main() {
	if err := app.Run(&Console{}); err != nil {
		log.Fatal(err)
	}
}
