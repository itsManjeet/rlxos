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
	"flag"
	"image"
	"image/png"
	"log"
	"os"
	"time"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
)

var (
	snapshot string
)

func init() {
	flag.StringVar(&snapshot, "snapshot", "", "Capture snapshot")
}

func main() {
	flag.Parse()

	d := &Display{
		Taskbar: Taskbar{
			Switcher: Switcher{
				Label: graphics.Label{
					BackgroundColor:     BackgroundColor,
					ForegroundColor:     graphics.ColorWhite,
					HorizontalAlignment: graphics.StartAlignment,
					Text:                "1  2  3",
				},
			},
			Clock: Clock{
				Label: graphics.Label{
					BackgroundColor:     BackgroundColor,
					ForegroundColor:     graphics.ColorWhite,
					HorizontalAlignment: graphics.MiddleAlignment,
				},
			},
			Status: Status{
				Label: graphics.Label{
					BackgroundColor:     BackgroundColor,
					ForegroundColor:     graphics.ColorWhite,
					HorizontalAlignment: graphics.EndAlignment,
				},
			},

			Box: graphics.Box{
				Orientation: graphics.Horizontal,
			},
			Height: 32,
		},
		Workspace: Workspace{
			BackgroundColor: BackgroundColor,
			MasterRatio:     0.6,
			MasterCount:     1,
		},
	}

	d.Taskbar.Append(&d.Taskbar.Switcher)
	d.Taskbar.Append(&d.Taskbar.Clock)
	d.Taskbar.Append(&d.Taskbar.Status)

	var err error
	if snapshot == "" {
		err = graphics.Run(d)
	} else {
		err = captureSnapshot(snapshot, d)
	}

	if err != nil {
		log.Fatal(err)
	}
}

func captureSnapshot(p string, w graphics.Widget) error {
	screen := argb.NewImage(image.Rect(0, 0, 800, 600))

	w.SetBounds(screen.Bounds())
	w.SetDirty(true)

	if u, ok := w.(graphics.Updatable); ok {
		u.Update(time.Now())
	}

	w.Draw(screen)

	file, err := os.OpenFile(p, os.O_WRONLY|os.O_CREATE, 0644)
	if err != nil {
		return err
	}
	defer file.Close()

	return png.Encode(file, screen)
}
