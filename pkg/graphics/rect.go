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
)

func Rect(dst draw.Image, r image.Rectangle, radius int, c color.Color, thickness int) {
	if radius <= 0 {
		Line(dst, r.Min, image.Pt(r.Max.X, r.Min.Y), c, thickness) // Top
		Line(dst, r.Min, image.Pt(r.Min.X, r.Max.Y), c, thickness) // Left
		Line(dst, image.Pt(r.Max.X, r.Min.Y), r.Max, c, thickness) // Right
		Line(dst, image.Pt(r.Min.X, r.Max.Y), r.Max, c, thickness) // Bottom
		return
	}

	// Horizontal lines (between corners)
	Line(dst, image.Pt(r.Min.X+radius, r.Min.Y), image.Pt(r.Max.X-radius, r.Min.Y), c, thickness) // Top
	Line(dst, image.Pt(r.Min.X+radius, r.Max.Y), image.Pt(r.Max.X-radius, r.Max.Y), c, thickness) // Bottom

	// Vertical lines (between corners)
	Line(dst, image.Pt(r.Min.X, r.Min.Y+radius), image.Pt(r.Min.X, r.Max.Y-radius), c, thickness) // Left
	Line(dst, image.Pt(r.Max.X, r.Min.Y+radius), image.Pt(r.Max.X, r.Max.Y-radius), c, thickness) // Right

	// Arcs (corners)
	Arc(dst, image.Pt(r.Min.X+radius, r.Min.Y+radius), radius, 180, 270, c, thickness) // Top-left
	Arc(dst, image.Pt(r.Max.X-radius, r.Min.Y+radius), radius, 270, 360, c, thickness) // Top-right
	Arc(dst, image.Pt(r.Min.X+radius, r.Max.Y-radius), radius, 90, 180, c, thickness)  // Bottom-left
	Arc(dst, image.Pt(r.Max.X-radius, r.Max.Y-radius), radius, 0, 90, c, thickness)    // Bottom-right
}

func FillRect(dst draw.Image, r image.Rectangle, radius int, c color.Color) {
	if radius <= 0 {
		Fill(dst, r, c)
		return
	}

	if radius > r.Dx()/2 {
		radius = r.Dx() / 2
	}
	if radius > r.Dy()/2 {
		radius = r.Dy() / 2
	}

	Fill(dst, image.Rect(r.Min.X+radius, r.Min.Y, r.Max.X-radius, r.Max.Y), c)
	Fill(dst, image.Rect(r.Min.X, r.Min.Y+radius, r.Min.X+radius, r.Max.Y-radius), c)
	Fill(dst, image.Rect(r.Max.X-radius, r.Min.Y+radius, r.Max.X, r.Max.Y-radius), c)

	FillArc(dst, image.Pt(r.Min.X+radius, r.Min.Y+radius), radius, 180, 270, c)
	FillArc(dst, image.Pt(r.Max.X-radius-1, r.Min.Y+radius), radius, 270, 360, c)
	FillArc(dst, image.Pt(r.Min.X+radius, r.Max.Y-radius-1), radius, 90, 180, c)
	FillArc(dst, image.Pt(r.Max.X-radius-1, r.Max.Y-radius-1), radius, 0, 90, c)
}
