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
	"image"
	"log"
	"path/filepath"
	"syscall"
	"unsafe"
)

type Manager struct {
	fd      int
	devices []*Device
}

func NewManager() (*Manager, error) {
	fd, err := syscall.EpollCreate1(0)
	if err != nil {
		return nil, err
	}

	m := &Manager{fd: fd}
	return m, nil
}

func (m *Manager) Close() error {
	for _, d := range m.devices {
		_ = d.Close()
	}
	return syscall.Close(m.fd)
}

func (m *Manager) RegisterAll(glob string) error {
	paths, err := filepath.Glob(glob)
	if err != nil {
		return err
	}
	for _, path := range paths {
		if err := m.Register(path); err != nil {
			log.Println("failed to register", path, err)
			continue
		}
	}
	log.Printf("Registered %d input devices", len(m.devices))
	return nil
}

func (m *Manager) Register(path string) error {
	dev, err := OpenDevice(path)
	if err != nil {
		return err
	}

	if err := m.RegisterDevice(dev); err != nil {
		_ = dev.Close()
		return err
	}

	m.devices = append(m.devices, dev)

	return nil
}

func (m *Manager) RegisterDevice(d *Device) error {
	ev := &syscall.EpollEvent{
		Events: syscall.EPOLLIN,
		Fd:     int32(d.FD()),
	}

	return syscall.EpollCtl(m.fd, syscall.EPOLL_CTL_ADD, d.fd, ev)
}

func (m *Manager) PollEvents() ([]Event, error) {
	epev := make([]syscall.EpollEvent, len(m.devices))

	n, err := syscall.EpollWait(m.fd, epev, 0)
	if err != nil {
		return nil, err
	}

	var events []Event
	var ev sysEvent
	buf := make([]byte, unsafe.Sizeof(ev))

	for i := 0; i < n; i++ {
		r, err := syscall.Read(m.devices[i].FD(), buf)
		if err != nil || r != int(unsafe.Sizeof(ev)) {
			continue
		}

		if err := binary.Read(bytes.NewReader(buf), binary.NativeEndian, &ev); err != nil {
			continue
		}

		switch ev.Type {
		case 0x01:
			if ev.Code >= 272 && ev.Code <= 279 {
				events = append(events, ButtonEvent{
					Button:  int(ev.Code),
					Pressed: ev.Value == 1,
				})
			} else {
				events = append(events, KeyEvent{
					Code:    int(ev.Code),
					Pressed: ev.Value == 1,
				})
			}
		case 0x02:
			switch ev.Code {
			case 0:
				events = append(events, CursorEvent{
					Point: image.Point{
						X: int(ev.Value),
					},
					Absolute: false,
				})
			case 1:
				events = append(events, CursorEvent{
					Point: image.Point{
						Y: int(ev.Value),
					},
					Absolute: false,
				})
			}
		case 0x03:
			switch ev.Code {
			case 0:
				events = append(events, CursorEvent{
					Point: image.Point{
						X: int(ev.Value),
					},
					Absolute: true,
				})
			case 1:
				events = append(events, CursorEvent{
					Point: image.Point{
						Y: int(ev.Value),
					},
					Absolute: true,
				})
			}
		case 0x04:
			if ev.Code == 0x04 {
				events = append(events, KeyEvent{
					Code:    int(ev.Value),
					Pressed: ev.Value == 1,
				})
			}
		default:
			events = append(events, ev)
		}
	}

	return events, nil
}
