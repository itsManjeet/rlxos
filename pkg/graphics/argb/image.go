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

import (
	"image"
	"image/color"
)

type Image struct {
	buf    []byte
	stride int
	rect   image.Rectangle
}

func NewImage(r image.Rectangle) *Image {
	return &Image{
		rect:   r,
		buf:    make([]byte, r.Dx()*r.Dy()*4),
		stride: r.Dy() * 4,
	}
}

func NewImageWithBuffer(r image.Rectangle, b []byte, stride int) *Image {
	return &Image{
		buf:    b,
		rect:   r,
		stride: stride,
	}
}

func (i *Image) Buffer() []byte {
	return i.buf
}

func (i *Image) ColorModel() color.Model {
	return ARGBModel
}

func (i *Image) Bounds() image.Rectangle {
	return i.rect
}

func (i *Image) At(x, y int) color.Color {
	if !(image.Point{X: x, Y: y}.In(i.rect)) {
		return Color(0)
	}
	off := i.pixelOffset(x, y)
	return Color(uint32(i.buf[off]) |
		uint32(i.buf[off+1])<<8 |
		uint32(i.buf[off+2])<<16 |
		uint32(i.buf[off+3])<<24)
}

func (i *Image) Set(x, y int, c color.Color) {
	if !(image.Point{X: x, Y: y}.In(i.rect)) {
		return
	}
	off := i.pixelOffset(x, y)
	var val Color
	if argb, ok := c.(Color); ok {
		val = argb
	} else {
		r, g, b, a := c.RGBA()
		val = NewColor(uint8(r>>8), uint8(g>>8), uint8(b>>8), uint8(a>>8))
	}
	i.buf[off+0] = byte(val)
	i.buf[off+1] = byte(val >> 8)
	i.buf[off+2] = byte(val >> 16)
	i.buf[off+3] = byte(val >> 24)
}

func (i *Image) pixelOffset(x, y int) int {
	return (y-i.rect.Min.Y)*i.stride + (x-i.rect.Min.X)*4
}
