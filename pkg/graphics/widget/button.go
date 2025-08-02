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

package widget

import (
	"image/color"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/button"
	"rlxos.dev/pkg/event/cursor"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/style"
)

type Button struct {
	Base

	OnClick func()

	BackgroundColor color.Color
	BorderColor     color.Color

	ActiveBackgroundColor color.Color
	ActiveBorderColor     color.Color

	BorderRadius int
	BorderWidth  int

	isActive bool
}

func (b *Button) OnStyleChange(s style.Style) {
	b.BackgroundColor = s.Primary
	b.BorderColor = style.Lighten(b.BackgroundColor, 0.2)

	b.ActiveBackgroundColor = style.Lighten(b.BackgroundColor, 0.4)
	b.ActiveBorderColor = style.Lighten(b.ActiveBackgroundColor, 0.1)

	b.BorderRadius = s.OutlineRadius
	b.BorderWidth = s.Outline

	b.Base.OnStyleChange(s)
}

func (b *Button) Update(ev event.Event) bool {
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
			return true
		}
	}
	return false
}

func (b *Button) Draw(cv canvas.Canvas) {
	borderColor := b.BorderColor
	backgroundColor := b.BackgroundColor
	if b.isActive {
		borderColor = b.ActiveBorderColor
		backgroundColor = b.ActiveBackgroundColor
	}

	graphics.FillRect(cv, b.Bounds(), b.BorderRadius, borderColor)
	graphics.Rect(cv, b.Bounds(), b.BorderRadius, backgroundColor)

	b.Base.Draw(cv)
}
