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

package graphics

import (
	"image"
	"image/draw"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/graphics/canvas"
)

const (
	TitlebarHeight = 28
	BorderWidth    = 2
)

type Window struct {
	BaseWidget

	Child Widget
}

func (w *Window) Draw(cv canvas.Canvas) {
	draw.Draw(cv, w.Bounds(), image.NewUniform(Background), image.Point{}, draw.Src)
	if w.Child != nil {
		if w.Child.Dirty() {
			w.Child.Draw(cv)
			w.Child.SetDirty(false)
		}
	}

	borderColor := ColorDarkGray
	draw.Draw(cv, image.Rect(w.Bounds().Min.X+BorderWidth, w.Bounds().Min.Y+TitlebarHeight, w.Bounds().Max.X-BorderWidth, w.Bounds().Min.Y),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

	draw.Draw(cv, image.Rect(w.Bounds().Min.X, w.Bounds().Max.Y, w.Bounds().Max.X, w.Bounds().Max.Y-BorderWidth),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

	draw.Draw(cv, image.Rect(w.Bounds().Min.X+BorderWidth, w.Bounds().Min.Y, w.Bounds().Min.X, w.Bounds().Max.Y),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

	draw.Draw(cv, image.Rect(w.Bounds().Max.X, w.Bounds().Min.Y, w.Bounds().Max.X-BorderWidth, w.Bounds().Max.Y),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

}

func (w *Window) Update(ev event.Event) {
	if u, ok := w.Child.(Updatable); ok {
		u.Update(ev)
	}
}

func (w *Window) SetBounds(rect image.Rectangle) {
	w.BaseWidget.SetBounds(rect)
	w.Child.SetBounds(image.Rect(
		rect.Min.X+BorderWidth,
		rect.Min.Y+TitlebarHeight,
		rect.Max.X-BorderWidth,
		rect.Max.Y-BorderWidth,
	))
}

func (w *Window) Dirty() bool {
	if w.Child != nil {
		if w.Child.Dirty() {
			return true
		}
	}
	return w.dirty
}
