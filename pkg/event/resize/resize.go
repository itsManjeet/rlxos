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

package resize

import "rlxos.dev/pkg/kernel/shm"

type Event struct {
	Key           int
	Width, Height int
}

func (e Event) Event() {}

func (e Event) SharedImage() (*shm.Image, error) {
	return shm.NewImageForKey(e.Key, e.Width, e.Width)
}
