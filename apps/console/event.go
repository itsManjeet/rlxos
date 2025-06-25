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
	"errors"
	"io"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/life"
	"rlxos.dev/pkg/kernel/vt"
)

type EventProvider struct {
	vt *vt.VT
}

func (ep *EventProvider) Fd() int {
	return ep.vt.Fd()
}

func (ep *EventProvider) Read() (event.Event, error) {
	buf := make([]byte, 1024)
	n, err := ep.vt.Read(buf)
	if err != nil {
		if errors.Is(err, io.EOF) {
			return life.End{}, nil
		}
		return nil, err
	}
	return VTEvent(buf[:n]), nil
}

type VTEvent []byte

func (e VTEvent) Event() {}
