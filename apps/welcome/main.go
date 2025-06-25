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
	"image"
	"log"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/app"
)

const welcomeMessage = `Welcome to RLXOS scratch
A Linux based operating system written from scratch in pure golang.
It's an experimental project and only for Proof of concept for now and a very few features are working right now.
**Please don't use to on real hardware (if it boot!).**

Here are few things you can try
- Left Alt + Enter -- To Launch console
- Left Alt + S     -- To Switch windows
- Left Alt + Q     -- To Kill active window
`

type Welcome struct {
	graphics.Box
	Label graphics.Label
}

func (w *Welcome) Init(rect image.Rectangle) error {
	w.Append(&w.Label)
	w.Label = graphics.Label{
		Text:                welcomeMessage,
		HorizontalAlignment: graphics.MiddleAlignment,
		VerticalAlignment:   graphics.MiddleAlignment,
		ForegroundColor:     graphics.ColorWhite,
	}
	return nil
}

func main() {
	if err := app.Run(&Welcome{}); err != nil {
		log.Fatal(err)
	}
}
