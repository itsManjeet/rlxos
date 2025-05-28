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

package graphics

import (
	"image/color"

	"rlxos.dev/pkg/graphics/argb"
)

var (
	Background   color.Color
	OnBackground color.Color
	Surface      color.Color
	OnSurface    color.Color

	Black = argb.NewColor(0x00, 0x00, 0x00, 0xff)
	White = argb.NewColor(0xff, 0xff, 0xff, 0xff)
)

func init() {
	Background = argb.NewColor(0x22, 0x22, 0x22, 0xff)
	OnBackground = argb.NewColor(0xff, 0xff, 0xff, 0xff)

	Surface = argb.NewColor(0x88, 0x88, 0x88, 0xff)
	OnSurface = argb.NewColor(0x11, 0x11, 0x11, 0xff)
}
