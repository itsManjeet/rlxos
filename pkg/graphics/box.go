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

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/graphics/canvas"
)

type Orientation int

const (
	Horizontal Orientation = iota
	Vertical
)

type Box struct {
	BaseContainer

	Orientation Orientation
}

func (b *Box) Foreach(f func(w Widget)) {
	for _, child := range b.Children() {
		f(child)
	}
}

func (b *Box) Update(ev event.Event) {
	b.Foreach(func(c Widget) {
		if u, ok := c.(Updatable); ok {
			u.Update(ev)
		}
	})
}

func (b *Box) Draw(canvas canvas.Canvas) {
	b.Foreach(func(c Widget) {
		if c.Dirty() {
			c.Draw(canvas)
			c.SetDirty(false)
		}
	})
}

func (b *Box) SetBounds(rect image.Rectangle) {
	b.BaseWidget.SetBounds(rect)

	total := len(b.Children())
	if total == 0 {
		return
	}

	switch b.Orientation {
	case Horizontal:
		childHeight := b.Bounds().Dy()
		childWidth := b.Bounds().Dx() / total
		for i, child := range b.children {
			x := b.Bounds().Min.X + i*childWidth
			y := b.Bounds().Min.Y
			child.SetBounds(image.Rect(x, y, x+childWidth, y+childHeight))
		}
	case Vertical:
		childHeight := b.Bounds().Dy() / total
		childWidth := b.Bounds().Dx()
		for i, child := range b.children {
			x := b.Bounds().Min.X
			y := b.Bounds().Min.Y + i*childWidth
			child.SetBounds(image.Rect(x, y, x+childWidth, y+childHeight))
		}
	}
}
