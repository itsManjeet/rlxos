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
	"image/draw"
	"math/rand"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/input"
)

type Display struct {
	graphics.BaseWidget

	Taskbar   Taskbar
	Workspace Workspace
	cursor    image.Point
}

func (d *Display) Update(event input.Event) {
	switch event := event.(type) {
	case input.CursorEvent:
		if event.Absolute {
			if event.X != 0 {
				d.cursor.X = event.X
			}

			if event.Y != 0 {
				d.cursor.Y = event.Y
			}
		} else {
			d.cursor.X += event.X
			d.cursor.Y += event.Y
		}
		d.SetDirty(true)
	case input.KeyEvent:
		if event.Code == input.KEY_P && event.Pressed {
			win := &Window{
				BackgroundColor: BackgroundColor,
				Content: graphics.Label{
					BackgroundColor: BackgroundColor,
					ForegroundColor: graphics.ColorWhite,
				},
			}
			win.SetBounds(d.pos(600, 400))
			win.isActive = true
			d.Workspace.Append(win)

			d.Workspace.Children()[d.Workspace.activeIndex].(*Window).isActive = false
			d.Workspace.Children()[d.Workspace.activeIndex].(*Window).SetDirty(true)

			d.Workspace.activeIndex = len(d.Workspace.Children()) - 1
			d.Workspace.SetDirty(true)

		} else if event.Code == input.KEY_R && event.Pressed {
			d.cursor.X = d.Bounds().Dx() / 2
			d.cursor.Y = d.Bounds().Dy() / 2
			d.BaseWidget.SetDirty(true)
		}
	}

	d.Workspace.Update(event)
	d.Taskbar.Update(event)
}

func (d *Display) Draw(canvas canvas.Canvas) {
	if d.Taskbar.Dirty() {
		d.Taskbar.Draw(canvas)
		d.Taskbar.SetDirty(false)
	}

	if d.Workspace.Dirty() {
		d.Workspace.Draw(canvas)
		d.Workspace.SetDirty(false)
	}

	draw.Draw(canvas, image.Rect(d.cursor.X, d.cursor.Y, d.cursor.X+2, d.cursor.Y+2), image.NewUniform(graphics.ColorWhite), image.Point{}, draw.Src)
}

func (d *Display) SetBounds(rect image.Rectangle) {
	d.BaseWidget.SetBounds(rect)

	d.Taskbar.SetBounds(image.Rect(rect.Min.X, rect.Min.Y, rect.Max.X, rect.Min.Y+d.Taskbar.Height))
	d.Workspace.SetBounds(image.Rect(rect.Min.X, rect.Min.Y+d.Taskbar.Height, rect.Max.X, rect.Max.Y))
}

func (d *Display) SetDirty(b bool) {
	d.BaseWidget.SetDirty(b)

	d.Taskbar.SetDirty(b)
	d.Workspace.SetDirty(b)
}

func (d *Display) Dirty() bool {
	return d.Taskbar.Dirty() || d.Workspace.Dirty() || d.BaseWidget.Dirty()
}

func (d *Display) pos(w, h int) image.Rectangle {
	maxX := d.Bounds().Max.X - w
	maxY := d.Bounds().Max.Y - h
	if maxX < 0 || maxY < 0 {
		return image.Rect(0, 0, 0, 0)
	}
	x := rand.Intn(maxX + 1)
	y := rand.Intn(maxY + 1)
	return image.Rect(x, y, x+w, y+h)
}
