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

package desktop

import (
	"image"
	"image/color"
	"image/draw"
	"log"
	"os/exec"
	"slices"
	"sync"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/service/display/screen"
	"rlxos.dev/service/display/surface"
)

type Desktop struct {
	graphics.BaseWidget

	Display screen.Display

	surfaces            []*surface.Surface
	activeSurface       *surface.Surface
	background          image.Image
	activeBorderColor   color.Color
	inactiveBorderColor color.Color
	surfaceBackground   color.Color
	surfaceBorderRadius int
	keys                key.Keys

	spacing int

	mutex sync.Mutex
}

func (d *Desktop) Init(rect image.Rectangle) error {
	d.background = image.NewUniform(argb.NewColor(26, 26, 26, 255))

	d.activeBorderColor = argb.NewColor(150, 150, 150, 255)
	d.inactiveBorderColor = argb.NewColor(50, 50, 50, 255)
	d.surfaceBackground = argb.NewColor(40, 40, 40, 255)
	d.surfaceBorderRadius = 4
	d.spacing = 10
	d.exec("/apps/welcome")
	return nil
}

func (d *Desktop) Draw(cv canvas.Canvas) {
	d.mutex.Lock()
	surfaces := d.surfaces
	d.mutex.Unlock()

	if d.BaseWidget.Dirty() {
		draw.Draw(cv, d.Bounds(), d.background, image.Point{}, draw.Src)
	}

	for _, s := range surfaces {
		if s.Dirty() {
			borderColor := d.inactiveBorderColor
			if s == d.activeSurface {
				borderColor = d.activeBorderColor
			}
			graphics.FillRect(cv, s.Bounds(), d.surfaceBorderRadius, d.surfaceBackground)
			graphics.Rect(cv, s.Bounds(), d.surfaceBorderRadius, borderColor)
			s.Draw(cv)
			s.SetDirty(false)
		}
	}
}

func (d *Desktop) Dirty() bool {
	for _, s := range d.surfaces {
		if s.Dirty() {
			return true
		}
	}
	return d.BaseWidget.Dirty()
}

func (d *Desktop) SetDirty(b bool) {
	for _, s := range d.surfaces {
		s.SetDirty(b)
	}
	d.BaseWidget.SetDirty(b)
}

func (d *Desktop) Update(ev event.Event) {
	d.mutex.Lock()
	if len(d.surfaces) > 0 {
		d.activeSurface = d.surfaces[len(d.surfaces)-1]
	}
	d.mutex.Unlock()

	switch ev := ev.(type) {
	case surface.Create:
		s, err := surface.NewSurface(ev.Rect, ev.Conn)
		if err != nil {
			log.Printf("failed to create surface: %v", err)
		}

		d.mutex.Lock()
		d.surfaces = append(d.surfaces, s)
		s.SetDirty(true)
		d.mutex.Unlock()

		if err := ev.Conn.Send("surface.Created", surface.Created{
			Id:   s.Image.Key(),
			Rect: s.Bounds(),
		}, nil); err != nil {
			log.Printf("failed to send surface.Created: %v", err)
		}

		d.Layout()

	case surface.Damage:
		d.mutex.Lock()
		if s, ok := d.surfaceFromConn(ev.Conn); ok {
			s.SetDirty(true)
		} else {
			d.SetDirty(true)
		}
		d.mutex.Unlock()

	case key.Keys:
		d.keys = ev

	case key.Event:
		if !d.handleBindings(ev) {
			d.propagate("key-event", ev)
		}
	}
}

func (d *Desktop) propagate(c string, payload any) {
	if d.activeSurface != nil {
		if err := d.activeSurface.Conn.Send(c, payload, nil); err != nil {
			log.Println("failed to propagate command:", c, payload, err)
		}
	}
}

func (d *Desktop) handleBindings(ev key.Event) bool {
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
					_ = d.surfaces[idx].Destroy()
					d.surfaces = slices.Delete(d.surfaces, idx, idx+1)
				}
				if len(d.surfaces) > 0 {
					d.activeSurface = d.surfaces[len(d.surfaces)-1]
				}
				d.mutex.Unlock()
			}

			d.mutex.Lock()
			d.Layout()
			d.mutex.Unlock()

		case key.KEY_UP:
			if d.activeSurface != nil {
				if d.isKeySet(key.KEY_LEFTSHIFT) {
					d.Move(-10, 0)
				} else {
					d.Resize(-10, 0)
				}
			}

		case key.KEY_DOWN:
			if d.activeSurface != nil {
				if d.isKeySet(key.KEY_LEFTSHIFT) {
					d.Move(10, 0)
				} else {
					d.Resize(10, 0)
				}
			}

		case key.KEY_LEFT:
			if d.activeSurface != nil {
				if d.isKeySet(key.KEY_LEFTSHIFT) {
					d.Move(0, -10)
				} else {
					d.Resize(0, -10)
				}
			}

		case key.KEY_RIGHT:
			if d.activeSurface != nil {
				if d.isKeySet(key.KEY_LEFTSHIFT) {
					d.Move(0, 10)
				} else {
					d.Resize(0, 10)
				}
			}
		default:
			return false
		}
		return true
	}
	return false
}

func (d *Desktop) Raise(s *surface.Surface) {
	d.mutex.Lock()
	defer d.mutex.Unlock()

	if d.activeSurface != nil {
		d.activeSurface.SetDirty(true)
	}

	idx := slices.Index(d.surfaces, s)
	if idx != -1 {
		d.surfaces = slices.Delete(d.surfaces, idx, idx+1)
	}

	d.surfaces = append(d.surfaces, s)
	d.activeSurface = s
	d.activeSurface.SetDirty(true)
}

func (d *Desktop) Move(top, left int) {
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

func (d *Desktop) Resize(top, left int) {
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

func (d *Desktop) surfaceFromConn(conn *connect.Connection) (*surface.Surface, bool) {
	idx := slices.IndexFunc(d.surfaces, func(s *surface.Surface) bool {
		return s.Conn == conn
	})
	if idx == -1 {
		return nil, false
	}
	return d.surfaces[idx], true
}

func (d *Desktop) isKeySet(key int) bool {
	if d.keys == nil {
		return false
	}

	if s, ok := d.keys[key]; ok {
		return s
	}
	return false
}

func (d *Desktop) exec(bin string, args ...string) {
	cmd := exec.Command(bin, args...)
	if err := cmd.Start(); err != nil {
		log.Printf("failed to start command: %v", err)
	}
}
