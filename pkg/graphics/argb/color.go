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

package argb

import "image/color"

type Color uint32

var ARGBModel color.Model = color.ModelFunc(argbModel)

func NewColor(r, g, b, a uint8) Color {
	return Color(uint32(a)<<24 | uint32(r)<<16 | uint32(g)<<8 | uint32(b))
}

func (c Color) RGBA() (r, g, b, a uint32) {
	a8 := uint32(c>>24) & 0xFF
	r8 := uint32(c>>16) & 0xFF
	g8 := uint32(c>>8) & 0xFF
	b8 := uint32(c) & 0xFF

	// Scale 8-bit to 16-bit
	r = (r8 << 8) | r8
	g = (g8 << 8) | g8
	b = (b8 << 8) | b8
	a = (a8 << 8) | a8
	return
}

func argbModel(c color.Color) color.Color {
	if col, ok := c.(Color); ok {
		return col
	}
	r, g, b, a := c.RGBA()
	return NewColor(
		uint8(r>>8),
		uint8(g>>8),
		uint8(b>>8),
		uint8(a>>8),
	)
}
