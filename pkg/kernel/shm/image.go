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

package shm

import (
	"image"
	"math/rand"

	"rlxos.dev/pkg/graphics/argb"
)

type Image struct {
	argb.Image
	mem Memory
	key int
}

func NewImage(width, height int) (*Image, error) {
	key := rand.Int()
	return NewImageForKey(key, width, height)
}

func NewImageForKey(key int, width, height int) (*Image, error) {
	// TODO: get bpp from format
	size := width * height * 4

	mem, err := Get(key, size, IPC_CREAT|0666)
	if err != nil {
		return nil, err
	}

	buf, err := mem.Attach(0, 0)
	if err != nil {
		return nil, err
	}

	return &Image{
		Image: *argb.NewImageWithBuffer(image.Rect(0, 0, width, height), buf, width*4),
		mem:   mem,
		key:   key,
	}, nil
}

func (i *Image) Detach() error {
	return i.mem.Detach(i.Buffer())
}

func (i *Image) Destroy() error {
	_ = i.Detach()
	return i.mem.Remove()
}

func (i *Image) Key() int {
	return i.key
}

func (i *Image) Size() int {
	return len(i.Buffer())
}
