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
	"image"
	"syscall"

	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/button"
	"rlxos.dev/pkg/event/cursor"
	"rlxos.dev/pkg/event/key"
)

type Device struct {
	fd int
}

func OpenDevice(path string) (*Device, error) {
	fd, err := syscall.Open(path, syscall.O_RDONLY, 0)
	if err != nil {
		return nil, err
	}
	return &Device{fd}, nil
}

func (d *Device) Close() error {
	return syscall.Close(d.fd)
}

func (d *Device) Fd() int {
	return d.fd
}

func (d *Device) Read() (event.Event, error) {
	ev, err := Read(d.fd)
	if err != nil {
		return nil, err
	}
	switch ev.Type {
	case 0x01:
		if ev.Code >= 272 && ev.Code <= 279 {
			return button.Event{
				Button: button.Button(ev.Code - 272),
				State:  button.State(ev.Value),
			}, nil
		} else {
			return key.Event{
				Key:   int(ev.Code),
				State: key.State(ev.Value),
			}, nil
		}
	case 0x02:
		switch ev.Code {
		case 0:
			return cursor.Event{
				Pos: image.Point{
					X: int(ev.Value),
				},
				Abs: true,
			}, nil
		case 1:
			return cursor.Event{
				Pos: image.Point{
					Y: int(ev.Value),
				},
				Abs: true,
			}, nil
		}
	case 0x03:
		switch ev.Code {
		case 0:
			return cursor.Event{
				Pos: image.Point{
					X: int(ev.Value),
				},
				Abs: false,
			}, nil
		case 1:
			return cursor.Event{
				Pos: image.Point{
					Y: int(ev.Value),
				},
				Abs: false,
			}, nil
		}
	case 0x04:
		if ev.Code == 0x04 {
			return key.Event{
				Key:   int(ev.Code),
				State: key.State(ev.Value),
			}, nil
		}
	}
	return nil, nil
}
