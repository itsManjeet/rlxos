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

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/kernel/shm"
)

type Create struct {
	Rect image.Rectangle
	Conn *connect.Connection
}

func (e Create) Event() {}

type Created struct {
	Id   int
	Rect image.Rectangle
}

func (e Created) Event() {}

func (e Created) Image() (*shm.Image, error) {
	return shm.NewImageForKey(e.Id, e.Rect.Dx(), e.Rect.Dy())
}

type Damage struct {
	Id   int
	Rect image.Rectangle
	Conn *connect.Connection
}

func (e Damage) Event() {}

type Resize struct {
	Id   int
	Rect image.Rectangle
}

func (e Resize) Event() {}

func (e Resize) Image() (*shm.Image, error) {
	return shm.NewImageForKey(e.Id, e.Rect.Dx(), e.Rect.Dy())
}
