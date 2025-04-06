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
 * General Public License for more detaild.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package terminal

func (d *Driver) Size() (int, int) {
	return d.width - 1, d.height - 1
}

func (d *Driver) Clear() {
	for y := range d.buffer {
		d.buffer[y] = ' '
	}
}

func (d *Driver) Set(x, y int, v any) {
	offset := y*d.width + x
	if offset < 0 || offset > len(d.buffer) {
		return
	}
	d.buffer[offset] = v.(rune)
}

func (d *Driver) DrawRectangle(x, y, w, h int) {
	hLine := '─'
	vLine := '│'
	tl := '┌'
	tr := '┐'
	bl := '└'
	br := '┘'

	d.Set(x, y, tl)
	d.Set(x+w-1, y, tr)
	d.Set(x, y+h-1, bl)
	d.Set(x+w-1, y+h-1, br)

	for i := 1; i < w-1; i++ {
		d.Set(x+i, y, hLine)
		d.Set(x+i, y+h-1, hLine)
	}

	for i := 1; i < h-1; i++ {
		d.Set(x, y+i, vLine)
		d.Set(x+w-1, y+i, vLine)
	}
}

func (d *Driver) DrawText(text string, x, y int, center bool) {
	if center {
		x = x - len(text)/2
	}
	for i, ch := range text {
		d.Set(x+i, y, ch)
		if x > d.width {
			x = 0
			y++
		}
	}
}
