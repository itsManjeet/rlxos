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

package vt

const (
	GETMODE         = 0x5601
	SETMODE         = 0x5602
	GETSTATE        = 0x5603
	RELEASE_DISPLAY = 0x5605
	ACTIVATE        = 0x5606
	WAITACTIVE      = 0x5607

	PROCESS     = 0x01
	ACKNOWLEDGE = 0x02
)

type Mode struct {
	Mode        int8
	Wait        int8
	Release     int16
	Acquisition int16
	_           int16
}

type State struct {
	Active uint16
	Signal uint16
	State  uint16
}
