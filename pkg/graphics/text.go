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
	"log"

	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
	"golang.org/x/image/math/fixed"
	"rlxos.dev/pkg/graphics/canvas"
)

//go:embed font.ttf
var fontBytes []byte

var (
	fonts *opentype.Font
	faces = map[int]font.Face{}
)

func init() {
	fonts, _ = opentype.Parse(fontBytes)
}

func Face(size int) font.Face {
	if f, ok := faces[size]; ok {
		return f
	}
	face, err := opentype.NewFace(fonts, &opentype.FaceOptions{
		Size:    float64(size),
		DPI:     100,
		Hinting: font.HintingFull,
	})
	if err != nil {
		log.Fatal(err)
	}
	faces[size] = face
	return face
}

func Text(cv canvas.Canvas, pos image.Point, text string, size int, col color.Color) {
	face := Face(size)
	d := &font.Drawer{
		Dst:  cv,
		Src:  image.NewUniform(col),
		Face: face,
		Dot:  fixed.P(pos.X, pos.Y),
	}
	d.DrawString(text)
}
