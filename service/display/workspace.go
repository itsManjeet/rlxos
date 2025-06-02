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
	"image/draw"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/input"
)

type Workspace struct {
	graphics.BaseContainer

	BackgroundColor color.Color
	MasterRatio     float64
	MasterCount     int
	activeIndex     int
}

func (w *Workspace) Draw(canvas canvas.Canvas) {
	if w.SelfDirty() {
		draw.Draw(canvas, w.Bounds(), image.NewUniform(BackgroundColor), image.Point{}, draw.Src)
		w.SetSelfDirty(false)
	}

	for _, child := range w.Children() {
		if child.Dirty() {
			child.Draw(canvas)
			child.SetDirty(false)
		}
	}
}

func (w *Workspace) Update(event input.Event) {
	if len(w.Children()) == 0 {
		return
	}
	switch event := event.(type) {
	case input.KeyEvent:
		if event.Code == input.KEY_TAB && event.Pressed {
			win, _ := w.Children()[w.activeIndex].(*Window)
			win.isActive = false
			win.SetDirty(true)

			w.activeIndex = (w.activeIndex + 1) % len(w.Children())

			win, _ = w.Children()[w.activeIndex].(*Window)
			win.isActive = true
			win.SetDirty(true)
		} else {
			if u, ok := w.Children()[w.activeIndex].(graphics.Updatable); ok {
				u.Update(event)
			}
		}
	default:
		if u, ok := w.Children()[w.activeIndex].(graphics.Updatable); ok {
			u.Update(event)
		}
	}
}
