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
	"strings"

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
	defer face.Close()

	labelBounds := l.Bounds()
	clippedCanvas := image.NewRGBA(labelBounds)
	if l.BackgroundColor != nil {
		draw.Draw(clippedCanvas, labelBounds, image.NewUniform(l.BackgroundColor), image.Point{}, draw.Src)
	}

	lineHeight := face.Metrics().Height.Ceil()
	padding := 4
	maxWidth := labelBounds.Dx() - padding*2
	maxHeight := labelBounds.Dy() - padding*2
	maxLines := maxHeight / lineHeight

	// Split input text by lines (preserving \n)
	rawLines := strings.Split(l.Text, "\n")
	var lines []string

	for _, rawLine := range rawLines {
		words := strings.Fields(rawLine)
		var line string
		for _, word := range words {
			testLine := line
			if testLine != "" {
				testLine += " "
			}
			testLine += word
			if font.MeasureString(face, testLine).Ceil() <= maxWidth {
				line = testLine
			} else {
				lines = append(lines, line)
				line = word
				if len(lines) >= maxLines {
					break
				}
			}
		}
		if line != "" && len(lines) < maxLines {
			lines = append(lines, line)
		}
		if len(lines) >= maxLines {
			break
		}
	}

	// Vertical alignment
	var startY int
	contentHeight := len(lines) * lineHeight
	switch l.VerticalAlignment {
	case StartAlignment:
		startY = labelBounds.Min.Y + padding + face.Metrics().Ascent.Ceil()
	case EndAlignment:
		startY = labelBounds.Max.Y - contentHeight - padding + face.Metrics().Ascent.Ceil()
	default:
		startY = labelBounds.Min.Y + (labelBounds.Dy()-contentHeight)/2 + face.Metrics().Ascent.Ceil()
	}

	// Draw each line
	for i, textLine := range lines {
		textWidth := font.MeasureString(face, textLine).Ceil()
		var x int
		switch l.HorizontalAlignment {
		case StartAlignment:
			x = labelBounds.Min.X + padding
		case EndAlignment:
			x = labelBounds.Max.X - textWidth - padding
		default:
			x = labelBounds.Min.X + (labelBounds.Dx()-textWidth)/2
		}

		y := startY + i*lineHeight
		d := &font.Drawer{
			Dst:  clippedCanvas,
			Src:  image.NewUniform(l.ForegroundColor),
			Face: face,
			Dot:  fixed.P(x, y),
		}
		d.DrawString(textLine)
	}

	// Blit the clipped canvas onto the main canvas
	draw.Draw(canvas, labelBounds, clippedCanvas, labelBounds.Min, draw.Src)
}

func FontSize(size int) (int, int) {
	face, _ := opentype.NewFace(fonts, &opentype.FaceOptions{
		Size:    float64(size),
		DPI:     100,
		Hinting: font.HintingFull,
	})
	defer face.Close()

	return int(font.MeasureString(face, "h").Ceil()), face.Metrics().Height.Ceil()
}
