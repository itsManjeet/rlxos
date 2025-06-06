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
	"rlxos.dev/pkg/graphics/canvas"
)

//go:embed font.ttf
var fontBytes []byte

var (
	fonts *opentype.Font
)

func init() {
	fonts, _ = opentype.Parse(fontBytes)
}

type Alignment int

const (
	StartAlignment Alignment = iota
	MiddleAlignment
	EndAlignment
)

type Label struct {
	BaseWidget

	Text                string
	HorizontalAlignment Alignment
	VerticalAlignment   Alignment
	BackgroundColor     color.Color
	ForegroundColor     color.Color
	Size                int
}

func (l *Label) Draw(canvas canvas.Canvas) {
	if l.ForegroundColor == nil {
		l.ForegroundColor = OnBackground
	}
	if l.Size == 0 {
		l.Size = 8
	}

	face, err := opentype.NewFace(fonts, &opentype.FaceOptions{
		Size:    float64(l.Size),
		DPI:     100,
		Hinting: font.HintingFull,
	})
	if err != nil {
		log.Fatal(err)
	}

	textWidth := font.MeasureString(face, l.Text).Round()
	textHeight := face.Metrics().Height.Round()

	var x, y int
	switch l.HorizontalAlignment {
	case StartAlignment:
		x = l.Bounds().Min.X + 4
	case EndAlignment:
		x = l.Bounds().Max.X - textWidth - 4
	default:
		x = l.Bounds().Min.X + (l.Bounds().Dx()-textWidth)/2
	}

	switch l.VerticalAlignment {
	case StartAlignment:
		y = l.Bounds().Min.Y + 4 + face.Metrics().Ascent.Round()
	case EndAlignment:
		y = l.Bounds().Max.Y - textHeight - 4 + face.Metrics().Ascent.Round()
	default:
		y = l.Bounds().Min.Y + (l.Bounds().Dy()-textHeight)/2 + face.Metrics().Ascent.Round()
	}

	d := &font.Drawer{
		Dst:  canvas,
		Src:  image.NewUniform(l.ForegroundColor),
		Face: face,
		Dot:  fixed.P(x, y),
	}

	if l.BackgroundColor != nil {
		draw.Draw(canvas, l.Bounds(), image.NewUniform(l.BackgroundColor), image.Point{}, draw.Src)
	}

	d.DrawString(l.Text)
}
