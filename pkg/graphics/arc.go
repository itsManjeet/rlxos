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

func Arc(dst draw.Image, center image.Point, radius, startDeg, endDeg int, clr color.Color, thickness int) {
	for deg := startDeg; deg <= endDeg; deg++ {
		rad := float64(deg) * (math.Pi / 180)
		x := center.X + int(float64(radius)*math.Cos(rad))
		y := center.Y + int(float64(radius)*math.Sin(rad))
		Dot(dst, image.Pt(x, y), clr, thickness)
	}
}

func FillArc(dst draw.Image, center image.Point, radius int, start, end float64, c color.Color) {
	startRad := start * (math.Pi / 180.0)
	endRad := end * (math.Pi / 180.0)

	if startRad > endRad {
		startRad, endRad = endRad, startRad
	}
	for y := -radius; y <= radius; y++ {
		for x := -radius; x <= radius; x++ {
			dist := x*x + y*y
			if dist <= radius*radius {
				angle := math.Atan2(float64(y), float64(x))
				if angle < 0 {
					angle += 2 * math.Pi
				}
				if angle >= startRad && angle <= endRad {
					dst.Set(center.X+x, center.Y+y, c)
				}
			}
		}
	}
}
