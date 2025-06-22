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
	"image/draw"
	"image/jpeg"
	"log"
	"os"
	"os/exec"
	"slices"
	"sync"

	"github.com/nfnt/resize"
	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/cursor"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/service/display/surface"
)

type Display struct {
	graphics.BaseWidget
	surfaces      []*surface.Surface
	activeSurface *surface.Surface
	background    image.Image
	spacing       int
	mutex         sync.Mutex
	cursor        image.Point
	keys          map[int]bool
}

func (d *Display) Init(rect image.Rectangle) error {
	d.spacing = 10
	file, err := os.OpenFile("/data/backgrounds/default.jpg", os.O_RDONLY, 0)
	if err == nil {
		defer file.Close()

		if background, err := jpeg.Decode(file); err == nil {
			d.background = resize.Resize(uint(rect.Dx()), uint(rect.Dy()), background, resize.Lanczos3)
		}
	}

	if d.background == nil {
		d.background = image.NewUniform(graphics.Background)
	}
	d.keys = map[int]bool{}
	return nil
}

func (d *Display) Draw(canvas canvas.Canvas) {
	d.mutex.Lock()
	surfaces := d.surfaces
	d.mutex.Unlock()

	if d.BaseWidget.Dirty() {
		draw.Draw(canvas, d.Bounds(), d.background, image.Point{}, draw.Src)
	}

	for _, s := range surfaces {
		if s.Dirty() {
			s.Draw(canvas)
			s.SetDirty(false)
		}
	}
}

func (d *Display) Update(ev event.Event) {
	d.mutex.Lock()
	if len(d.surfaces) > 0 {
		d.activeSurface = d.surfaces[len(d.surfaces)-1]
	}
	d.mutex.Unlock()

	switch ev := ev.(type) {
	case cursor.Event:
		if ev.Abs {
			if ev.Pos.X != 0 {
				d.cursor.X = ev.Pos.X
			}
			if ev.Pos.Y != 0 {
				d.cursor.Y = ev.Pos.Y
			}
		} else {
			d.cursor.X += ev.Pos.X
			d.cursor.Y += ev.Pos.Y
		}
		if d.activeSurface != nil {
			if d.cursor.In(d.activeSurface.Bounds()) {
				d.propagate("cursor-event", d.cursor)
			}
		}

	case key.Event:
		d.keys[ev.Key] = ev.State == key.Pressed
		if !d.handleBindings(ev) {
			d.propagate("key-event", ev)
		}

	case SurfaceEvent:
		switch sev := ev.event.(type) {
		case surface.Create:
			s, err := surface.NewSurface(sev.Rect, ev.conn)
			if err != nil {
				log.Printf("failed to create surface: %v", err)
			}

			d.mutex.Lock()
			d.surfaces = append(d.surfaces, s)
			d.mutex.Unlock()

			if err := ev.conn.Send("surface.Created", surface.Created{
				Id:   s.Image.Key(),
				Rect: s.Bounds(),
			}, nil); err != nil {
				log.Printf("failed to send surface.Created: %v", err)
			}

			d.mutex.Lock()
			d.Layout()
			d.mutex.Unlock()

		case surface.Damage:
			d.mutex.Lock()
			if s, ok := d.surfaceFromId(sev.Id); ok {
				s.SetDirty(true)
			}
			d.mutex.Unlock()
		}
	}
}

func (d *Display) propagate(c string, payload any) {
	if d.activeSurface != nil {
		if err := d.activeSurface.Conn.Send(c, payload, nil); err != nil {
			log.Println("failed to propagate command:", c, payload, err)
		}
	}
}

func (d *Display) Dirty() bool {
	if d.BaseWidget.Dirty() {
		return true
	}
	for _, s := range d.surfaces {
		if s.Dirty() {
			return true
		}
	}
	return false
}

func (d *Display) SetDirty(b bool) {
	d.BaseWidget.SetDirty(b)
	for _, s := range d.surfaces {
		s.SetDirty(b)
	}
}

func (d *Display) isKeySet(key int) bool {
	if s, ok := d.keys[key]; ok {
		return s
	}
	return false
}

func (d *Display) exec(bin string, args ...string) {
	cmd := exec.Command(bin, args...)
	if err := cmd.Start(); err != nil {
		log.Printf("failed to start command: %v", err)
	}
}

func (d *Display) handleBindings(ev key.Event) bool {
	if d.isKeySet(key.KEY_LEFTALT) && ev.State == key.Pressed {
		switch ev.Key {
		case key.KEY_ENTER:
			d.exec("/apps/console")
			return true
		case key.KEY_S:
			if len(d.surfaces) > 0 {
				d.Raise(d.surfaces[0])
				d.SetDirty(true)
			}

		case key.KEY_Q:
			if d.activeSurface != nil {
				d.mutex.Lock()
				idx := slices.Index(d.surfaces, d.activeSurface)
				if idx != -1 {
					d.surfaces = slices.Delete(d.surfaces, idx, idx+1)
					d.SetDirty(true)
				}
				if len(d.surfaces) > 0 {
					d.activeSurface = d.surfaces[len(d.surfaces)-1]
				}
				d.Layout()
				d.mutex.Unlock()
			}

		case key.KEY_R:
			d.SetDirty(true)

		default:
			return false
		}
		return true
	}
	return false
}

func (d *Display) Raise(s *surface.Surface) {
	d.mutex.Lock()
	defer d.mutex.Unlock()

	idx := slices.Index(d.surfaces, s)
	if idx != -1 {
		d.surfaces = slices.Delete(d.surfaces, idx, idx+1)
	}

	d.surfaces = append(d.surfaces, s)
	d.activeSurface = s
}

func (d *Display) Move(top, left int) {
	if d.activeSurface != nil {
		log.Println("Moving surface", top, left)
		rect := d.activeSurface.Bounds()
		d.activeSurface.SetBounds(image.Rect(
			rect.Min.X+left,
			rect.Min.Y+top,
			rect.Max.X+left,
			rect.Max.Y+top,
		))
		d.activeSurface.SetDirty(true)
	}
}

func (d *Display) Resize(top, left int) {
	if d.activeSurface != nil {
		log.Println("Resizing surface", top, left)
		rect := d.activeSurface.Bounds()
		d.activeSurface.SetBounds(image.Rect(
			rect.Min.X,
			rect.Min.Y,
			rect.Max.X+left,
			rect.Max.Y+top,
		))
		d.activeSurface.SetDirty(true)
	}
}

func (d *Display) surfaceFromId(id int) (*surface.Surface, bool) {
	idx := slices.IndexFunc(d.surfaces, func(s *surface.Surface) bool {
		return s.Image.Key() == id
	})
	if idx == -1 {
		return nil, false
	}
	return d.surfaces[idx], true
}
