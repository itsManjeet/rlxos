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
	_ "embed"
	"image"
	"image/color"
	"image/draw"
	"log"

	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
)

//go:embed font.ttf
var fontBytes []byte

var (
	fonts *opentype.Font
)

func init() {
	fonts, _ = opentype.Parse(fontBytes)
}

func Text(dst draw.Image, bounds image.Rectangle, text string, size int, c color.Color) {
	face, err := opentype.NewFace(fonts, &opentype.FaceOptions{
		Size:    float64(size),
		DPI:     100,
		Hinting: font.HintingFull,
	})
	if err != nil {
		log.Fatal(err)
	}

	textWidth := font.MeasureString(face, text).Round()
	textHeight := face.Metrics().Height.Round()

	x := bounds.Min.X + (bounds.Dx()-textWidth)/2
	y := bounds.Min.Y + (bounds.Dy()-textHeight)/2 + face.Metrics().Ascent.Round()

	d := &font.Drawer{
		Dst:  dst,
		Src:  image.NewUniform(c),
		Face: face,
		Dot:  fixed.P(x, y),
	}
	d.DrawString(text)
}
