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

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/cursor"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/widget"
	"rlxos.dev/service/display/screen"
	"rlxos.dev/service/display/screen/desktop"
)

type Display struct {
	widget.Base

	screen screen.Screen
	cursor image.Point
	keys   key.Keys
}

func (d *Display) Construct() {
	d.keys = key.Keys{}
	d.SetScreen(&desktop.Desktop{Display: d})

	d.Base.Construct()
}

func (d *Display) SetBounds(rect image.Rectangle) {
	d.Base.SetBounds(rect)
	d.screen.SetBounds(rect)
}

func (d *Display) Draw(cv canvas.Canvas) {
	d.screen.Draw(cv)
}

func (d *Display) Update(ev event.Event) bool {
	switch ev := ev.(type) {
	case cursor.Event:
		if ev.Abs {
			if ev.Pos.X != 0 {
				d.cursor.X = ev.Pos.X
			}
			if ev.Pos.Y != 0 {
				d.cursor.Y = ev.Pos.Y
			}
		} else {
			d.cursor.X += ev.Pos.X
			d.cursor.Y += ev.Pos.Y
		}

	case key.Event:
		d.keys[ev.Key] = ev.State == key.Pressed
		d.screen.Update(d.keys)
	}

	return d.screen.Update(ev)
}

func (d *Display) SetScreen(s screen.Screen) {
	d.screen = s
	d.screen.Construct()
}

func (d *Display) Dirty() bool {
	return d.screen.Dirty() || d.Base.Dirty()
}

func (d *Display) SetDirty(b bool) {
	d.Base.SetDirty(b)
	d.screen.SetDirty(b)
}
