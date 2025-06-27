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

package drmkms

import (
	"fmt"
	"image"
	"image/draw"
	"log"
	"path/filepath"
	"sync"
	"syscall"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/drm"
	"rlxos.dev/pkg/kernel/input"
	"rlxos.dev/pkg/kernel/poll"
)

type Framebuffer struct {
	id      uint32
	backend *drm.Framebuffer
	buffer  []byte
}

type Backend struct {
	mutex     sync.Mutex
	card      *drm.Card
	listener  *poll.Listener
	buffers   []Framebuffer
	next      int
	crtc      *drm.Crtc
	mode      drm.ModeInfo
	connector *drm.Connector
}

func (d *Backend) Terminate() {
	_ = d.card.Close()
}

func (d *Backend) Init() (err error) {
	d.card, err = drm.OpenCard("/dev/dri/card0")
	if err != nil {
		return err
	}

	if err := d.setupCard(); err != nil {
		_ = d.card.Close()
		return err
	}

	if d.listener, err = poll.NewListener(0); err != nil {
		_ = d.card.Close()
		return err
	}

	if err := d.listenInputDevices(); err != nil {
		_ = d.card.Close()
		_ = d.listener.Close()
		return err
	}

	return nil
}

func (d *Backend) Canvas() canvas.Canvas {
	return argb.NewImageWithBuffer(
		image.Rect(0, 0, int(d.mode.Hdisplay), int(d.mode.Vdisplay)),
		d.buffers[d.next].buffer,
		int(d.buffers[d.next].backend.Pitch),
	)
}

func (d *Backend) Update() {
	connectors := []uint32{d.connector.ID}
	if err := d.card.SetCrtc(d.crtc.ID, d.buffers[d.next].id, 0, 0, &connectors[0], 1, &d.mode); err != nil {
		log.Printf("failed to flip: %v", err)
	} else {
		d.prepareBackBuffer()
		d.next ^= 1
	}
}

func (d *Backend) PollEvents() ([]event.Event, error) {
	return d.listener.Poll()
}

func (d *Backend) prepareBackBuffer() {
	src := argb.NewImageWithBuffer(
		image.Rect(0, 0, int(d.mode.Hdisplay), int(d.mode.Vdisplay)),
		d.buffers[d.next].buffer,
		int(d.buffers[d.next].backend.Pitch),
	)
	dst := argb.NewImageWithBuffer(
		image.Rect(0, 0, int(d.mode.Hdisplay), int(d.mode.Vdisplay)),
		d.buffers[d.next^1].buffer,
		int(d.buffers[d.next^1].backend.Pitch),
	)
	draw.Draw(dst, dst.Bounds(), src, image.Point{}, draw.Src)
}

func (d *Backend) setupCard() error {
	if !d.card.Support(drm.CapDumbBuffer) {
		return fmt.Errorf("card doesn't support dumb buffer")
	}

	resources, err := d.card.GetResources()
	if err != nil {
		return fmt.Errorf("failed to get DRM resources: %v", err)
	}

	found := false
	for _, connID := range resources.Connectors {
		conn, err := d.card.GetConnector(connID)
		if err != nil {
			continue
		}
		if conn.Connection == drm.Connected && len(conn.Modes) > 0 {
			d.connector = conn
			found = true
			break
		}
	}

	if !found {
		return fmt.Errorf("no connected connector with valid modes found")
	}

	d.crtc, err = d.card.GetCrtc(resources.Crtcs[0])
	if err != nil {
		return fmt.Errorf("failed to get CRTC: %v", err)
	}

	d.mode = d.connector.Modes[0]

	d.buffers = make([]Framebuffer, 2)
	for i := 0; i < 2; i++ {
		dumb, err := d.card.CreateDumb(d.mode.Hdisplay, d.mode.Vdisplay, 32)
		if err != nil {
			return fmt.Errorf("failed to create dumb buffer: %v", err)
		}
		fbID, err := d.card.AddFramebuffer(d.mode.Hdisplay, d.mode.Vdisplay, 24, 32, dumb.Pitch, dumb.Handle)
		if err != nil {
			return fmt.Errorf("failed to add framebuffer: %v", err)
		}
		offset, err := d.card.MapDumb(dumb.Handle)
		if err != nil {
			return fmt.Errorf("failed to map dumb buffer: %v", err)
		}

		buffer, err := syscall.Mmap(d.card.Fd(), int64(offset), int(dumb.Size), syscall.PROT_WRITE|syscall.PROT_READ, syscall.MAP_SHARED)
		if err != nil {
			return fmt.Errorf("failed to map dumb buffer: %v", err)
		}
		d.buffers[i] = Framebuffer{id: fbID, backend: dumb, buffer: buffer}
	}

	connectors := []uint32{d.connector.ID}

	if err := d.card.SetCrtc(d.crtc.ID, d.buffers[0].id, 0, 0, &connectors[0], 1, &d.mode); err != nil {
		return fmt.Errorf("failed to set CRTC: %v", err)
	}
	return nil
}

func (d *Backend) listenInputDevices() error {
	matches, err := filepath.Glob("/dev/input/event*")
	if err != nil {
		return err
	}

	for _, match := range matches {
		src, err := input.OpenDevice(match)
		if err != nil {
			continue
		}
		if err := d.Listen(src); err != nil {
			_ = src.Close()
			continue
		}
	}
	return nil
}

func (d *Backend) Listen(source event.Source) error {
	d.mutex.Lock()
	defer d.mutex.Unlock()

	return d.listener.Add(source)
}
