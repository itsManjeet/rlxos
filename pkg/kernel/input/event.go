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

package input

import (
	"bytes"
	"encoding/binary"
	"fmt"
	"syscall"
	"unsafe"
)

type Event struct {
	Time  [2]uint64
	Type  uint16
	Code  uint16
	Value int32
}

func Read(fd int) (Event, error) {
	var ev Event
	buf := make([]byte, unsafe.Sizeof(ev))

	r, err := syscall.Read(fd, buf)
	if err != nil || r != int(unsafe.Sizeof(ev)) {
		return Event{}, fmt.Errorf("failed to read event: %w", err)
	}

	if err := binary.Read(bytes.NewReader(buf), binary.NativeEndian, &ev); err != nil {
		return Event{}, fmt.Errorf("failed to read event: %w", err)
	}
	return ev, nil
}
