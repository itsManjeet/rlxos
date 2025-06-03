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

	"github.com/nfnt/resize"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/input"
)

type Workspace struct {
	graphics.BaseContainer

	BackgroundImage image.Image
	MasterRatio     float64
	MasterCount     int
	activeWindow    *Window
}

func (w *Workspace) Draw(canvas canvas.Canvas) {
	if w.SelfDirty() {
		if !w.Bounds().Eq(w.BackgroundImage.Bounds()) {
			w.BackgroundImage = resize.Resize(uint(w.Bounds().Dx()), uint(w.Bounds().Dy()), w.BackgroundImage, resize.Bilinear)
		}
		draw.Draw(canvas, w.Bounds(), w.BackgroundImage, image.Point{}, draw.Src)
		w.SetSelfDirty(false)
	}

	for _, child := range w.Children() {
		if child.Dirty() {
			child.Draw(canvas)
			child.SetDirty(true)
		}
	}
}

func (w *Workspace) Update(event input.Event) {
	if w.activeWindow != nil {
		w.activeWindow.Update(event)
	}
}

func (w *Workspace) addWindow(_ string) {
	if w.activeWindow != nil {
		w.activeWindow.isActive = false
		w.SetDirty(true)
	}

	w.activeWindow = &Window{
		BackgroundColor: BackgroundColor,
		isActive:        true,
		Content: graphics.Label{
			HorizontalAlignment: graphics.StartAlignment,
			VerticalAlignment:   graphics.StartAlignment,
			BackgroundColor:     BackgroundColor,
			Size:                8,
		},
	}
	w.activeWindow.SetDirty(true)
	w.activeWindow.SetBounds(pos(600, 400, w.Bounds()))
	w.Append(w.activeWindow)
}

func (w *Workspace) at(pos image.Point) *Window {
	children := w.Children()
	for i := len(children) - 1; i >= 0; i-- {
		if pos.In(children[i].Bounds()) {
			return children[i].(*Window)
		}
	}
	return nil
}

func (w *Workspace) Raise(win *Window) {
	w.activeWindow.isActive = false
	w.activeWindow.SetDirty(true)

	w.activeWindow = win
	w.activeWindow.isActive = true
	w.activeWindow.SetDirty(true)

	w.Append(win)
}
