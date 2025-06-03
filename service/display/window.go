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

type Window struct {
	graphics.BaseWidget

	BackgroundColor color.Color
	isActive        bool
	Content         graphics.Label
}

func (w *Window) Draw(canvas canvas.Canvas) {
	w.Content.Draw(canvas)

	var borderColor color.Color = BorderColor
	if w.isActive {
		borderColor = ActiveBorderColor
	}
	draw.Draw(canvas, image.Rect(w.Bounds().Min.X-BorderWidth, w.Bounds().Min.Y-TitlebarHeight, w.Bounds().Max.X+BorderWidth, w.Bounds().Min.Y),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

	draw.Draw(canvas, image.Rect(w.Bounds().Min.X, w.Bounds().Max.Y, w.Bounds().Max.X, w.Bounds().Max.Y+BorderWidth),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

	draw.Draw(canvas, image.Rect(w.Bounds().Min.X-BorderWidth, w.Bounds().Min.Y, w.Bounds().Min.X, w.Bounds().Max.Y),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

	draw.Draw(canvas, image.Rect(w.Bounds().Max.X, w.Bounds().Min.Y, w.Bounds().Max.X+BorderWidth, w.Bounds().Max.Y),
		image.NewUniform(borderColor), image.Point{}, draw.Src)

}

func (w *Window) SetBounds(rect image.Rectangle) {
	w.BaseWidget.SetBounds(rect)
	w.Content.SetBounds(rect)
}

func (w *Window) Update(event input.Event) {
	switch event := event.(type) {
	case input.KeyEvent:
		if event.Pressed {
			if key, ok := keymap[event.Code]; ok {
				w.Content.Text += string(key)
				w.SetDirty(true)
			} else if event.Code == input.KEY_BACKSPACE {
				if len(w.Content.Text) == 1 {
					w.Content.Text = ""
					w.SetDirty(true)
				} else if len(w.Content.Text) > 1 {
					w.Content.Text = w.Content.Text[:len(w.Content.Text)-1]
					w.SetDirty(true)
				}
			} else if event.Code == input.KEY_SPACE {
				w.Content.Text += " "
				w.SetDirty(true)
			}
		}
	}
}
