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

	"rlxos.dev/pkg/event/resize"
	"rlxos.dev/pkg/kernel/shm"
)

type Surface struct {
	*shm.Image
	pos   image.Point
	conn  *Connection
	dirty bool
}

func NewSurface(rect image.Rectangle, conn *Connection) (*Surface, error) {
	img, err := shm.NewImage(rect.Dx(), rect.Dy())
	if err != nil {
		return nil, err
	}
	return &Surface{
		Image: img,
		pos:   image.Point{X: rect.Min.X, Y: rect.Min.Y},
		conn:  conn,
	}, nil
}

func (s *Surface) Destroy() error {
	_ = s.Image.Destroy()
	return nil
}

func (s *Surface) SetBounds(rect image.Rectangle) (err error) {
	s.pos = rect.Min
	if s.Image.Bounds().Dx() == rect.Dx() || s.Image.Bounds().Dy() == rect.Dy() {
		return
	}

	_ = s.Image.Destroy()
	s.Image, err = shm.NewImage(rect.Dx(), rect.Dy())
	if err != nil {
		return fmt.Errorf("shm.NewImage: %w", err)
	}

	log.Println("Resizing", rect)
	return s.conn.Send("resize", resize.Event{
		Key:    s.Image.Key(),
		Width:  rect.Dx(),
		Height: rect.Dy(),
	}, nil)
}

func (s *Surface) Dirty() bool {
	return s.dirty
}

func (s *Surface) SetDirty(d bool) {
	s.dirty = d
}
