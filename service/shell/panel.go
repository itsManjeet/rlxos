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
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/argb"
	"rlxos.dev/pkg/kernel/shm"
)

type Panel struct {
	img *shm.Image
}

func NewPanel(width, height int) (*Panel, error) {
	img, err := shm.NewImage(width, 48)
	if err != nil {
		return nil, err
	}

	p := &Panel{
		img: img,
	}
	return p, nil
}

func (p *Panel) Update() {
	graphics.Clear(p.img, argb.NewColor(255, 255, 255, 255))
}
