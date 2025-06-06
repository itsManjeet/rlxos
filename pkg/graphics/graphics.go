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
	"math"

	"rlxos.dev/pkg/graphics/canvas"
)

func Rect(cv canvas.Canvas, r image.Rectangle, radius int, col color.Color) {
	x0, y0 := r.Min.X, r.Min.Y
	x1, y1 := r.Max.X-1, r.Max.Y-1

	for x := x0 + radius; x <= x1-radius; x++ {
		cv.Set(x, y0, col)
		cv.Set(x, y1, col)
	}
	for y := y0 + radius; y <= y1-radius; y++ {
		cv.Set(x0, y, col)
		cv.Set(x1, y, col)
	}

	Arc(cv, image.Pt(x0+radius, y0+radius), radius, math.Pi, 3*math.Pi/2, col)   // top-left
	Arc(cv, image.Pt(x1-radius, y0+radius), radius, 3*math.Pi/2, 2*math.Pi, col) // top-right
	Arc(cv, image.Pt(x0+radius, y1-radius), radius, math.Pi/2, math.Pi, col)     // bottom-left
	Arc(cv, image.Pt(x1-radius, y1-radius), radius, 0, math.Pi/2, col)           // bottom-right
}

func Line(cv canvas.Canvas, r image.Rectangle, col color.Color) {
	dx := abs(r.Max.X - r.Min.X)
	sx := 1
	if r.Min.X > r.Max.X {
		sx = -1
	}
	dy := -abs(r.Max.Y - r.Min.Y)
	sy := 1
	if r.Min.Y > r.Max.Y {
		sy = -1
	}
	err := dx + dy

	for {
		cv.Set(r.Min.X, r.Min.Y, col)
		if r.Min.X == r.Max.X && r.Min.Y == r.Max.Y {
			break
		}
		e2 := 2 * err
		if e2 >= dy {
			err += dy
			r.Min.X += sx
		}
		if e2 <= dx {
			err += dx
			r.Min.Y += sy
		}
	}
}

func Arc(cv canvas.Canvas, pos image.Point, r int, start, end float64, col color.Color) {
	steps := r * 8
	for i := 0; i <= steps; i++ {
		theta := start + float64(i)*(end-start)/float64(steps)
		x := pos.X + int(float64(r)*math.Cos(theta))
		y := pos.Y + int(float64(r)*math.Sin(theta))
		cv.Set(x, y, col)
	}
}

func FillRect(cv canvas.Canvas, r image.Rectangle, radius int, col color.Color) {
	x0, y0 := r.Min.X, r.Min.Y
	x1, y1 := r.Max.X-1, r.Max.Y-1

	// Fill center
	for y := y0 + radius; y <= y1-radius; y++ {
		for x := x0; x <= x1; x++ {
			cv.Set(x, y, col)
		}
	}

	// Fill vertical sides
	for y := y0; y < y0+radius; y++ {
		for x := x0 + radius; x <= x1-radius; x++ {
			cv.Set(x, y, col)
		}
	}
	for y := y1 - radius + 1; y <= y1; y++ {
		for x := x0 + radius; x <= x1-radius; x++ {
			cv.Set(x, y, col)
		}
	}

	// Fill corners with filled arcs
	FillArc(cv, image.Pt(x0+radius, y0+radius), radius, math.Pi, 3*math.Pi/2, col)   // top-left
	FillArc(cv, image.Pt(x1-radius, y0+radius), radius, 3*math.Pi/2, 2*math.Pi, col) // top-right
	FillArc(cv, image.Pt(x0+radius, y1-radius), radius, math.Pi/2, math.Pi, col)     // bottom-left
	FillArc(cv, image.Pt(x1-radius, y1-radius), radius, 0, math.Pi/2, col)           // bottom-right
}

func FillArc(cv canvas.Canvas, pos image.Point, r int, start, end float64, col color.Color) {
	steps := r * 8
	for i := 0; i < steps; i++ {
		theta := start + float64(i)*(end-start)/float64(steps)
		x := pos.X + int(float64(r)*math.Cos(theta))
		y := pos.Y + int(float64(r)*math.Sin(theta))
		Line(cv, image.Rectangle{
			Min: pos,
			Max: image.Pt(x, y),
		}, col)
	}
}

func abs(x int) int {
	if x > 0 {
		return x
	}
	return -x
}
