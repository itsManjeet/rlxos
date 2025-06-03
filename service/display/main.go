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
	"image/color"
	"image/jpeg"
	"image/png"
	"log"
	"os"
	"time"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
)

var (
	snapshot   string
	background string
)

func init() {
	flag.StringVar(&snapshot, "snapshot", "", "Capture snapshot")
	flag.StringVar(&background, "background", "/data/backgrounds/default.jpg", "Background")
}

func main() {
	flag.Parse()
	backgroundImage := LoadBackgroundOrColor(background, BackgroundColor)

	d := &Display{
		Taskbar: Taskbar{
			Switcher: Switcher{
				Label: graphics.Label{
					BackgroundColor:     BackgroundColor,
					HorizontalAlignment: graphics.StartAlignment,
					VerticalAlignment:   graphics.MiddleAlignment,
				},
			},
			Clock: Clock{
				Label: graphics.Label{
					BackgroundColor:     BackgroundColor,
					HorizontalAlignment: graphics.MiddleAlignment,
					VerticalAlignment:   graphics.MiddleAlignment,
				},
			},
			Status: Status{
				Label: graphics.Label{
					BackgroundColor:     BackgroundColor,
					HorizontalAlignment: graphics.EndAlignment,
					VerticalAlignment:   graphics.MiddleAlignment,
				},
			},

			Box: graphics.Box{
				Orientation: graphics.Horizontal,
			},
			Height: 32,
		},
		Workspaces: []Workspace{
			{
				BackgroundImage: backgroundImage,
				MasterRatio:     0.6,
				MasterCount:     1,
			},
			{
				BackgroundImage: backgroundImage,
				MasterRatio:     0.6,
				MasterCount:     1,
			},
			{
				BackgroundImage: backgroundImage,
				MasterRatio:     0.6,
				MasterCount:     1,
			},
			{
				BackgroundImage: backgroundImage,
				MasterRatio:     0.6,
				MasterCount:     1,
			},
		},
	}
	d.Taskbar.Switcher.ActiveWorkspace = d.activeWorkspace
	d.Taskbar.Switcher.TotalWorkspaces = len(d.Workspaces)

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

func LoadBackground(path string) (image.Image, error) {
	file, err := os.OpenFile(path, os.O_RDONLY, 0)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	return jpeg.Decode(file)
}

func LoadBackgroundOrColor(path string, clr color.Color) image.Image {
	if img, err := LoadBackground(path); err == nil {
		return img
	}
	return image.NewUniform(clr)
}
