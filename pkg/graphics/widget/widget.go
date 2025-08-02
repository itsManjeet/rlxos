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
	"image"
	"slices"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/style"
)

type Widget interface {
	Construct()
	Destroy()

	Draw(canvas canvas.Canvas)

	Bounds() image.Rectangle
	SetBounds(rect image.Rectangle)

	Dirty() bool
	SetDirty(d bool)

	Update(event event.Event) bool

	OnStyleChange(style.Style)
}

type Base struct {
	Layout   func(base Widget, children []Widget) bool
	Children []Widget

	rect  image.Rectangle
	dirty bool
}

func (b *Base) Construct() {
	for _, ch := range b.Children {
		ch.Construct()
	}
}

func (b *Base) Destroy() {
	for _, ch := range b.Children {
		ch.Destroy()
	}
}

func (b *Base) Bounds() image.Rectangle {
	return b.rect
}

func (b *Base) SetBounds(rect image.Rectangle) {
	if !b.rect.Eq(rect) {
		b.SetDirty(true)
	}
	b.rect = rect

	if b.Layout != nil {
		changed := b.Layout(b, b.Children)
		if changed {
			b.SetDirty(true)
		}
	}
}

func (b *Base) Draw(cv canvas.Canvas) {
	for _, ch := range b.Children {
		// if ch.Dirty() {
		ch.Draw(cv)
		// 	ch.SetDirty(false)
		// }
	}
	b.dirty = false
}

func (b *Base) Update(ev event.Event) bool {
	for _, child := range b.Children {
		if child.Update(ev) {
			return true
		}
	}
	return false
}

func (b *Base) Dirty() bool {
	for _, child := range b.Children {
		if child.Dirty() {
			return true
		}
	}
	return b.dirty
}

func (b *Base) SetDirty(d bool) {
	b.dirty = d
	if d {
		for _, child := range b.Children {
			child.SetDirty(d)
		}
	}
}

func (b *Base) OnStyleChange(s style.Style) {
	for _, ch := range b.Children {
		ch.OnStyleChange(s)
	}
}

func (b *Base) AddChild(w Widget) {
	b.Children = append(b.Children, w)
	if b.Layout != nil {
		b.Layout(b, b.Children)
	}
}

func (b *Base) RemoveChild(w Widget) {
	idx := slices.Index(b.Children, w)
	if idx != -1 {
		b.Children = slices.Delete(b.Children, idx, idx+1)
		if b.Layout != nil {
			b.Layout(b, b.Children)
		}
	}
}
