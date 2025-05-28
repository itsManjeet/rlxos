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
	"math"
)

func Line(dst draw.Image, start, end image.Point, clr color.Color, thickness int) {
	dx := int(math.Abs(float64(end.X - start.X)))
	dy := int(math.Abs(float64(end.Y - start.Y)))
	sx := 1
	if start.X > end.X {
		sx = -1
	}
	sy := 1
	if start.Y > end.Y {
		sy = -1
	}
	err := dx - dy

	for {
		Dot(dst, start, clr, thickness)

		if start.X == end.X && start.Y == end.Y {
			break
		}
		e2 := 2 * err
		if e2 > -dy {
			err -= dy
			start.X += sx
		}
		if e2 < dx {
			err += dx
			start.Y += sy
		}
	}
}
