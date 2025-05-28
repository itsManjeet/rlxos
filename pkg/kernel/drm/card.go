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

package drm

import (
	"fmt"
	"syscall"
)

type Card struct {
	fd int
}

func OpenCard(path string) (*Card, error) {
	fd, err := syscall.Open(path, syscall.O_RDWR|syscall.O_CLOEXEC, 0)
	if err != nil {
		return nil, fmt.Errorf("failed to open DRM device: %w", err)
	}

	card := &Card{fd: fd}
	return card, nil
}

func (c *Card) Fd() int {
	return c.fd
}

func (c *Card) Close() error {
	return syscall.Close(c.fd)
}

func (c *Card) RestoreCrtc(dev *Modeset, saved *Crtc) error {
	connectors := []uint32{dev.Connector}
	if err := c.SetCrtc(
		saved.ID,
		saved.BufferID,
		saved.X,
		saved.Y,
		&connectors[0],
		len(connectors),
		&saved.ModeInfo,
	); err != nil {
		return fmt.Errorf("failed to restore CRTC: %w", err)
	}
	return nil
}
