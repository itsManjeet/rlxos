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
	"math/rand"
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
)

type Display struct {
	graphics.BaseWidget
	surfaces      []*Surface
	activeSurface *Surface
	background    image.Image
	damage        []image.Rectangle
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

	for _, surface := range surfaces {
		if surface.Dirty() {
			draw.Draw(canvas, image.Rectangle{
				Min: surface.pos,
				Max: image.Pt(surface.pos.X+surface.Bounds().Dx(), surface.pos.Y+surface.Bounds().Dy()),
			}, surface, image.Point{}, draw.Over)
			surface.SetDirty(false)
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
				d.mutex.Lock()

				d.mutex.Unlock()
				d.propagate("cursor-event", d.cursor)
			}
		}

	case key.Event:
		d.keys[ev.Key] = ev.State == key.Pressed
		if !d.handleBindings(ev) {
			d.propagate("key-event", ev)
		}

	case AddWindow:
		surface, err := NewSurface(ev.rect, ev.connection)
		if err != nil {
			log.Printf("failed to create surface: %v", err)
		}

		surface.pos = image.Point{
			X: rand.Intn(d.Bounds().Dx()-surface.Image.Bounds().Dx()+1) + d.Bounds().Min.X,
			Y: rand.Intn(d.Bounds().Dy()-surface.Image.Bounds().Dy()+1) + d.Bounds().Min.Y,
		}

		d.mutex.Lock()
		d.surfaces = append(d.surfaces, surface)
		d.mutex.Unlock()

		if err := ev.connection.Send("add-window", surface.Key(), nil); err != nil {
			log.Printf("failed to send add-window: %v", err)
		}
		surface.SetDirty(true)

	case Damage:
		d.mutex.Lock()
		d.damage = append(d.damage, ev.rect)
		d.mutex.Unlock()
		d.SetDirty(true)
	}
}

func (d *Display) propagate(c string, payload any) {
	if d.activeSurface != nil {
		if err := d.activeSurface.conn.Send(c, payload, nil); err != nil {
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
				}
				if len(d.surfaces) > 0 {
					d.activeSurface = d.surfaces[len(d.surfaces)-1]
				}
				d.mutex.Unlock()

				d.SetDirty(true)
			}
		}
	}
	return false
}

func (d *Display) Raise(s *Surface) {
	d.mutex.Lock()
	defer d.mutex.Unlock()

	idx := slices.Index(d.surfaces, s)
	if idx != -1 {
		d.surfaces = slices.Delete(d.surfaces, idx, idx+1)
	}

	d.surfaces = append(d.surfaces, s)
	d.activeSurface = s
}
