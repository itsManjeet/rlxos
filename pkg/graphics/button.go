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
	"image/color"
	"image/draw"

	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/input"
)

type Button struct {
	BaseWidget

	Child   Widget
	OnClick func()

	isActive bool
}

func (b *Button) Update(event input.Event) {
	switch event := event.(type) {
	case input.CursorEvent:
		isActive := event.In(b.Bounds())
		if b.isActive != isActive {
			b.SetDirty(true)
			b.isActive = isActive
		}

	case input.ButtonEvent:
		if event.Pressed && b.isActive && b.OnClick != nil {
			b.OnClick()
		}
	}
}

func (b *Button) Draw(canvas canvas.Canvas) {
	var backgroundColor color.Color

	if b.isActive {
		backgroundColor = Lighten(Primary, 0.3)
	} else {
		backgroundColor = Primary
	}

	draw.Draw(canvas, b.Bounds(), image.NewUniform(backgroundColor), image.Point{}, draw.Src)
	if b.Child.Dirty() {
		b.Child.Draw(canvas)
	}
}

func (b *Button) SetBounds(rect image.Rectangle) {
	b.BaseWidget.SetBounds(rect)
	b.Child.SetBounds(rect)
}
