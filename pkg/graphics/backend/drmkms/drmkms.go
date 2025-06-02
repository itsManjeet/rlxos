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
	"syscall"

	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/drm"
	"rlxos.dev/pkg/kernel/input"
)

type Framebuffer struct {
	id      uint32
	backend *drm.Framebuffer
	buffer  []byte
}

type Backend struct {
	card      *drm.Card
	inputs    *input.Manager
	buffers   []Framebuffer
	next      int
	crtc      *drm.Crtc
	mode      drm.ModeInfo
	connector *drm.Connector
}

func (d *Backend) Terminate() {
	_ = d.card.Close()
}

func (d *Backend) Init() error {
	card, err := drm.OpenCard("/dev/dri/card0")
	if err != nil {
		return err
	}
	// defer card.Close()

	if !card.Support(drm.CapDumbBuffer) {
		return fmt.Errorf("card doesn't support dumb buffer")
	}

	resources, err := card.GetResources()
	if err != nil {
		return fmt.Errorf("failed to get DRM resources: %v", err)
	}

	found := false
	for _, connID := range resources.Connectors {
		conn, err := card.GetConnector(connID)
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

	d.crtc, err = card.GetCrtc(resources.Crtcs[0])
	if err != nil {
		return fmt.Errorf("failed to get CRTC: %v", err)
	}

	d.mode = d.connector.Modes[0]

	d.buffers = make([]Framebuffer, 2)
	for i := 0; i < 2; i++ {
		dumb, err := card.CreateDumb(d.mode.Hdisplay, d.mode.Vdisplay, 32)
		if err != nil {
			return fmt.Errorf("failed to create dumb buffer: %v", err)
		}
		fbID, err := card.AddFramebuffer(d.mode.Hdisplay, d.mode.Vdisplay, 24, 32, dumb.Pitch, dumb.Handle)
		if err != nil {
			return fmt.Errorf("failed to add framebuffer: %v", err)
		}
		offset, err := card.MapDumb(dumb.Handle)
		if err != nil {
			return fmt.Errorf("failed to map dumb buffer: %v", err)
		}

		buffer, err := syscall.Mmap(card.Fd(), int64(offset), int(dumb.Size), syscall.PROT_WRITE|syscall.PROT_READ, syscall.MAP_SHARED)
		if err != nil {
			return fmt.Errorf("failed to map dumb buffer: %v", err)
		}
		d.buffers[i] = Framebuffer{id: fbID, backend: dumb, buffer: buffer}
	}

	connectors := []uint32{d.connector.ID}

	if err := card.SetCrtc(d.crtc.ID, d.buffers[0].id, 0, 0, &connectors[0], 1, &d.mode); err != nil {
		return fmt.Errorf("failed to set CRTC: %v", err)
	}

	inputs, err := input.NewManager()
	if err != nil {
		return fmt.Errorf("failed to initialize input manager %v", err)
	}
	// defer inputs.Close()

	if err := inputs.RegisterAll("/dev/input/event*"); err != nil {
		return fmt.Errorf("failed to register input devices %v", err)
	}

	d.card, card = card, nil
	d.inputs, inputs = inputs, nil
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

func (d *Backend) PollEvents() []input.Event {
	events, _ := d.inputs.PollEvents()
	return events
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
