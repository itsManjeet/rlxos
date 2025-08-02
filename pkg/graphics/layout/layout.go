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

package layout

import (
	"image"

	"rlxos.dev/pkg/graphics/widget"
)

type Layout func(widget.Widget, []widget.Widget) bool

func Horizontal(p widget.Widget, children []widget.Widget) bool {
	total := len(children)
	if total == 0 {
		return false
	}
	childHeight := p.Bounds().Dy()
	childWidth := p.Bounds().Dx() / total
	for i := range children {
		x := p.Bounds().Min.X + i*childWidth
		y := p.Bounds().Min.Y
		children[i].SetBounds(image.Rect(x, y, x+childWidth, y+childHeight))
	}
	return true
}

func Vertical(p widget.Widget, children []widget.Widget) bool {
	total := len(children)
	if total == 0 {
		return false
	}
	childHeight := p.Bounds().Dy() / total
	childWidth := p.Bounds().Dx()
	for i := range children {
		x := p.Bounds().Min.X
		y := p.Bounds().Min.Y + i*childHeight
		children[i].SetBounds(image.Rect(x, y, x+childWidth, y+childHeight))
	}
	return true
}
