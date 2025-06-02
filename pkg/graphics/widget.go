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

	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/input"
)

type Widget interface {
	Draw(canvas canvas.Canvas)
	Bounds() image.Rectangle
	SetBounds(rect image.Rectangle)
	Dirty() bool
	SetDirty(d bool)
}

type Updatable interface {
	Update(event input.Event)
}

type BaseWidget struct {
	rect  image.Rectangle
	dirty bool
}

func (b *BaseWidget) Bounds() image.Rectangle {
	return b.rect
}

func (b *BaseWidget) SetBounds(rect image.Rectangle) {
	if !b.rect.Eq(rect) {
		b.SetDirty(true)
	}
	b.rect = rect
}

func (b *BaseWidget) Dirty() bool {
	return b.dirty
}

func (b *BaseWidget) SetDirty(d bool) {
	b.dirty = d
}
