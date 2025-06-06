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

package main

import (
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"log"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/graphics/canvas"
)

type Welcome struct {
	graphics.Box
	Label graphics.Label
	color color.Color
}

func (w *Welcome) Init(rect image.Rectangle) error {
	w.color = argb.NewColor(255, 0, 0, 255)
	w.Append(&w.Label)
	w.Label = graphics.Label{
		Text:                "Welcome to rlxos",
		HorizontalAlignment: graphics.MiddleAlignment,
		VerticalAlignment:   graphics.MiddleAlignment,
		BackgroundColor:     nil,
	}
	return nil
}

func (w *Welcome) Draw(cv canvas.Canvas) {
	draw.Draw(cv, w.Bounds(), image.NewUniform(w.color), image.Point{}, draw.Over)
	w.Box.Draw(cv)
}

func (w *Welcome) Update(ev event.Event) {
	w.Label.Text = "Key Event: " + fmt.Sprint(ev)
	w.SetDirty(true)
}

func main() {
	if err := graphics.Run(&Welcome{}); err != nil {
		log.Fatal(err)
	}
}
