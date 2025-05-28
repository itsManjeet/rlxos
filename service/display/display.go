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
	"log"
	"syscall"

	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/kernel/drm"
)

type Framebuffer struct {
	id      uint32
	backend *drm.Framebuffer
	buffer  []byte
}

type Display struct {
	card      *drm.Card
	buffers   []Framebuffer
	next      int
	crtc      *drm.Crtc
	mode      drm.ModeInfo
	connector *drm.Connector
}

func OpenDisplay(path string) (*Display, error) {
	card, err := drm.OpenCard(path)
	if err != nil {
		return nil, err
	}
	d := &Display{card: card}

	if err := d.initialize(); err != nil {
		_ = card.Close()
		return nil, err
	}

	return d, nil
}

func (d *Display) Close() error {
	return d.card.Close()
}

func (d *Display) initialize() error {
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

func (d *Display) Image() *argb.Image {
	return argb.NewImageWithBuffer(
		image.Rect(0, 0, int(d.mode.Hdisplay), int(d.mode.Vdisplay)),
		d.buffers[d.next].buffer,
		int(d.buffers[d.next].backend.Pitch),
	)
}

func (d *Display) Sync() {
	connectors := []uint32{d.connector.ID}
	if err := d.card.SetCrtc(d.crtc.ID, d.buffers[d.next].id, 0, 0, &connectors[0], 1, &d.mode); err != nil {
		log.Printf("failed to flip: %v", err)
	} else {
		d.next ^= 1
	}
}
