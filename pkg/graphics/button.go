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

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/button"
	"rlxos.dev/pkg/event/cursor"
	"rlxos.dev/pkg/graphics/canvas"
)

type Button struct {
	BaseWidget

	Child   Widget
	OnClick func()

	isActive bool
}

func (b *Button) Update(ev event.Event) {
	switch ev := ev.(type) {
	case cursor.Event:
		isActive := ev.Pos.In(b.Bounds())
		if b.isActive != isActive {
			b.SetDirty(true)
			b.isActive = isActive
		}

	case button.Event:
		if ev.State == button.Pressed && b.isActive && b.OnClick != nil {
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
