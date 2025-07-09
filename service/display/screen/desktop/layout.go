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

import "image"

func (d *Desktop) Layout() {
	count := len(d.surfaces)

	if count == 0 {
		d.SetDirty(true)
		return
	}

	d.activeSurface = d.surfaces[len(d.surfaces)-1]

	bounds := d.Bounds()
	screenWidth, screenHeight := bounds.Dx(), bounds.Dy()

	masterRatio := 0.6
	padding := 10

	if count == 1 {
		d.surfaces[0].SetBounds(image.Rect(
			bounds.Min.X+padding,
			bounds.Min.Y+padding,
			bounds.Max.X-padding,
			bounds.Max.Y-padding,
		))
		d.SetDirty(true)
		return
	}

	masterWidth := int(float64(screenWidth)*masterRatio) - padding
	stackCount := count - 1
	stackHeight := (screenHeight - padding*(stackCount+1)) / stackCount

	d.surfaces[0].SetBounds(image.Rect(
		bounds.Min.X+padding,
		bounds.Min.Y+padding,
		bounds.Min.X+padding+masterWidth,
		bounds.Max.Y-padding,
	))

	for i := 0; i < stackCount; i++ {
		top := bounds.Min.Y + padding + i*(stackHeight+padding)
		bottom := top + stackHeight

		if i == stackCount-1 {
			bottom = bounds.Max.Y - padding
		}

		d.surfaces[i+1].SetBounds(image.Rect(
			bounds.Min.X+padding+masterWidth+padding,
			top,
			bounds.Max.X-padding,
			bottom,
		))
	}

	d.SetDirty(true)
}
