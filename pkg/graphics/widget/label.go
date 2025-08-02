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

package widget

import (
	_ "embed"
	"image"
	"image/color"
	"image/draw"
	"strings"

	"golang.org/x/image/font"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/alignment"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/style"
)

type Label struct {
	Base

	Text                string
	HorizontalAlignment alignment.Alignment
	VerticalAlignment   alignment.Alignment

	Color color.Color

	Size int
}

func (l *Label) OnStyleChange(s style.Style) {
	l.Color = s.OnPrimary
	l.Size = s.Paragraph
}

func (l *Label) Draw(canvas canvas.Canvas) {
	labelBounds := l.Bounds()
	clippedCanvas := image.NewRGBA(labelBounds)

	face := graphics.Face(l.Size)

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
	case alignment.Start:
		startY = labelBounds.Min.Y + padding + face.Metrics().Ascent.Ceil()
	case alignment.End:
		startY = labelBounds.Max.Y - contentHeight - padding + face.Metrics().Ascent.Ceil()
	default:
		startY = labelBounds.Min.Y + (labelBounds.Dy()-contentHeight)/2 + face.Metrics().Ascent.Ceil()
	}

	// Draw each line
	for i, textLine := range lines {
		textWidth := font.MeasureString(face, textLine).Ceil()
		var x int
		switch l.HorizontalAlignment {
		case alignment.Start:
			x = labelBounds.Min.X + padding
		case alignment.End:
			x = labelBounds.Max.X - textWidth - padding
		default:
			x = labelBounds.Min.X + (labelBounds.Dx()-textWidth)/2
		}

		y := startY + i*lineHeight
		graphics.Text(clippedCanvas, image.Pt(x, y), textLine, l.Size, l.Color)
	}

	draw.Draw(canvas, labelBounds, clippedCanvas, labelBounds.Min, draw.Src)
}
