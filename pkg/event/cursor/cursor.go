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

package cursor

import (
	"fmt"
	"image"
)

type Event struct {
	Pos image.Point
	Abs bool
}

func (e Event) Event() {}

func (e Event) String() string {
	var kind string
	if e.Abs {
		kind = "Absolute"
	} else {
		kind = "Relative"
	}

	return fmt.Sprintf("[Cursor(%vx%v:%s)]", e.Pos.X, e.Pos.Y, kind)
}
