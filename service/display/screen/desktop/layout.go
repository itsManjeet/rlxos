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

package desktop

import (
	"image"

	"rlxos.dev/pkg/graphics/widget"
)

func Tile(s widget.Widget, children []widget.Widget) bool {
	count := len(children)
	if count == 0 {
		return false
	}

	bounds := s.Bounds()
	screenWidth, screenHeight := bounds.Dx(), bounds.Dy()

	masterRatio := 0.6

	if count == 1 {
		children[0].SetBounds(bounds)
		return true
	}

	masterWidth := int(float64(screenWidth) * masterRatio)
	stackCount := count - 1
	stackHeight := (screenHeight - (stackCount + 1)) / stackCount

	children[0].SetBounds(image.Rect(
		bounds.Min.X,
		bounds.Min.Y,
		bounds.Min.X+masterWidth,
		bounds.Max.Y,
	))

	for i := 0; i < stackCount; i++ {
		top := bounds.Min.Y + i*stackHeight
		bottom := top + stackHeight

		if i == stackCount-1 {
			bottom = bounds.Max.Y
		}

		children[i+1].SetBounds(image.Rect(
			bounds.Min.X+masterWidth,
			top,
			bounds.Max.X,
			bottom,
		))
	}

	return true
}
