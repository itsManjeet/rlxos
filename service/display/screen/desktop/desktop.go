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
	"fmt"
	"image"
	"os"
	"os/exec"
	"syscall"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/key"
	"rlxos.dev/pkg/graphics/widget"
	"rlxos.dev/service/display/screen"
	"rlxos.dev/service/display/surface"
)

const (
	DEFAULT_TERMINAL_EMULATOR = "/apps/console"
	DEFAULT_WELCOME_APP       = "/apps/welcome"
)

type Desktop struct {
	widget.Base

	Display   screen.Display
	workspace Workspace
	status    Status

	keys key.Keys
}

func (d *Desktop) Construct() {
	d.AddChild(&d.status)
	d.AddChild(&d.workspace)

	d.exec(DEFAULT_TERMINAL_EMULATOR)

	d.Base.Construct()
}

func (d *Desktop) SetBounds(rect image.Rectangle) {
	d.Base.SetBounds(rect)

	d.status.SetBounds(image.Rect(
		d.Bounds().Min.X, d.Bounds().Min.Y,
		d.Bounds().Max.X, d.Bounds().Min.Y+48,
	))

	d.workspace.SetBounds(image.Rect(
		d.status.Bounds().Min.X, d.status.Bounds().Max.Y,
		d.Bounds().Max.X, d.Bounds().Max.Y,
	))
}

func (d *Desktop) Update(ev event.Event) bool {
	switch ev := ev.(type) {
	case surface.Create:
		s, err := surface.NewSurface(ev.Rect, ev.Conn)
		if err != nil {
			d.setStatus("failed to create surface: %v", err)
			return true
		}

		d.workspace.AddChild(s)
		if err := ev.Conn.Send("surface.Created", surface.Created{
			Id:   s.Image.Key(),
			Rect: s.Bounds(),
		}, nil); err != nil {
			d.setStatus("failed to send surface.Created: %v", err)
			return true
		}

	case surface.Damage:
		if s, ok := d.workspace.surfaceFromConn(ev.Conn); ok {
			s.SetDirty(true)
		} else {
			d.setStatus("no surface found for damage, damaging all")
			d.SetDirty(true)
		}

	case key.Keys:
		d.keys = ev

	case key.Event:
		if !d.handleBindings(ev) {
			if err := d.workspace.propagate("key-event", ev); err != nil {
				d.setStatus("failed to propogate key event: %v", err)
			}
		}
	}
	return true
}

func (d *Desktop) handleBindings(ev key.Event) bool {
	if d.isKeySet(key.KEY_LEFTALT) && ev.State == key.Pressed {
		switch ev.Key {
		case key.KEY_ENTER:
			term := os.Getenv("TERMINAL")
			if term == "" {
				term = DEFAULT_TERMINAL_EMULATOR
			}
			d.exec(term)
			return true
		case key.KEY_S:
			idx := (d.workspace.activeIndex() + 1) % len(d.workspace.Children)
			d.setStatus("Window %v", idx)
			d.workspace.Raise(idx)
		case key.KEY_Q:
			d.workspace.RemoveChild(d.workspace.activeSurface)
			d.workspace.SetDirty(true)

		case key.KEY_R:
			d.workspace.SetDirty(true)
			d.SetDirty(true)
			d.Display.SetDirty(true)

		default:
			return false
		}
		return true
	}
	return false
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
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Setsid: true,
	}

	if err := cmd.Start(); err != nil {
		d.setStatus("failed to start command: %v", err)
	}
}

func (d *Desktop) setStatus(format string, args ...interface{}) {
	d.status.pushNotification(fmt.Sprintf(format, args...))
}
