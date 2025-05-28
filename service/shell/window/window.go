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

package window

import (
	"image"

	"rlxos.dev/pkg/kernel/shm"
)

type Window struct {
	img *shm.Image

	pos image.Point
}

func NewWindow(x, y, width, height int) (*Window, error) {
	img, err := shm.NewImage(width, height)
	if err != nil {
		return nil, err
	}

	w := &Window{
		img: img,
		pos: image.Pt(x, y),
	}

	return w, nil
}

func (w *Window) Destroy() error {
	return w.img.Destroy()
}

func (w *Window) Resize(width, height int) (err error) {
	if w.img != nil {
		w.img.Destroy()
	}

	w.img.Destroy()

	w.img, err = shm.NewImage(width, height)
	if err != nil {
		return
	}

	return
}

func (w *Window) SetPosition(pos image.Point) {
	w.pos = pos
}

func (w *Window) Size() (int, int) {
	return w.img.Bounds().Dx(), w.img.Bounds().Dy()
}

func (w *Window) Position() image.Point {
	return w.pos
}

func (w *Window) Image() *shm.Image {
	return w.img
}
