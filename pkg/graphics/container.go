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

import "slices"

type Container interface {
	Children() []Widget
	Append(child Widget)
}

type BaseContainer struct {
	BaseWidget
	children []Widget
}

func (b *BaseContainer) Children() []Widget {
	return b.children
}

func (b *BaseContainer) Append(child Widget) {
	b.children = append(b.children, child)
}

func (b *BaseContainer) Remove(idx int) {
	b.children = slices.Delete(b.children, idx, idx+1)
}

func (b *BaseContainer) SelfDirty() bool {
	return b.dirty
}

func (b *BaseContainer) SetSelfDirty(d bool) {
	b.dirty = d
}

func (b *BaseContainer) Dirty() bool {
	for _, child := range b.children {
		if child.Dirty() {
			return true
		}
	}
	return b.dirty
}

func (b *BaseContainer) SetDirty(d bool) {
	b.dirty = d
	for _, child := range b.children {
		child.SetDirty(d)
	}
}
