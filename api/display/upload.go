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

package display

import (
	"image"

	"rlxos.dev/pkg/kernel/shm"
)

type UploadArgs struct {
	Key    int
	Bounds image.Rectangle
}

func UploadArgsFromImage(img *shm.Image, pos image.Point) UploadArgs {
	return UploadArgs{
		Key:    img.Key(),
		Bounds: image.Rect(pos.X, pos.Y, img.Bounds().Dx()+pos.X, img.Bounds().Dy()+pos.Y),
	}
}

func (u *UploadArgs) GetSharedImage() (*shm.Image, error) {
	return shm.NewImageForKey(u.Key, u.Bounds.Dx(), u.Bounds.Dy())
}

type UploadReply struct {
}
