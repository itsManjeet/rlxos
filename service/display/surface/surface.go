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

package surface

import (
	"image"
	"image/draw"
	"log"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/shm"
)

type Surface struct {
	graphics.BaseWidget

	Image *shm.Image
	Conn  *connect.Connection
}

func NewSurface(rect image.Rectangle, conn *connect.Connection) (*Surface, error) {
	img, err := shm.NewImage(rect.Dx(), rect.Dy())
	if err != nil {
		return nil, err
	}
	s := &Surface{
		Image: img,
		Conn:  conn,
	}
	s.SetBounds(rect)
	return s, nil
}

func (s *Surface) Destroy() error {
	_ = s.Image.Destroy()
	return nil
}

func (s *Surface) SetBounds(rect image.Rectangle) {
	s.BaseWidget.SetBounds(rect)
	if s.Image.Bounds().Dx() == rect.Dx() && s.Image.Bounds().Dy() == rect.Dy() {
		return
	}
	s.SetDirty(true)

	newImage, err := shm.NewImage(rect.Dx(), rect.Dy())
	if err != nil {
		log.Printf("shm.NewImage: %v", err)
		return
	}

	oldImage := s.Image
	s.Image = newImage

	ev := Resize{
		Id:   s.Image.Key(),
		Rect: s.Image.Bounds(),
	}
	log.Println("Resizing", ev)
	if err := s.Conn.Send("surface.Resize", ev, nil); err != nil {
		log.Printf("failed to send resize event %v", err)
	}

	_ = oldImage.Destroy()
}

func (s *Surface) Draw(cv canvas.Canvas) {
	draw.Draw(cv, s.Bounds(), s.Image, image.Point{}, draw.Src)
}
