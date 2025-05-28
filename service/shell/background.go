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
	"image/draw"
	_ "image/jpeg"
	"os"

	"github.com/nfnt/resize"
	"rlxos.dev/pkg/kernel/shm"
)

func LoadBackground(width, height int) (*shm.Image, error) {
	f, err := os.OpenFile("/data/backgrounds/default.jpg", os.O_RDONLY, 0)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	img, format, err := image.Decode(f)
	if err != nil {
		return nil, err
	}

	if format != "jpeg" {
		return nil, fmt.Errorf("unsupported background image")
	}

	img = resize.Resize(uint(width), uint(height), img, resize.Bilinear)

	bg, err := shm.NewImage(img.Bounds().Dx(), img.Bounds().Dy())
	if err != nil {
		return nil, err
	}
	draw.Draw(bg, bg.Bounds(), img, image.Point{}, draw.Over)

	return bg, nil
}
