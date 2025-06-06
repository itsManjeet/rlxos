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

package poll

import (
	"errors"
	"fmt"
	"syscall"

	"rlxos.dev/pkg/event"
)

type Listener struct {
	sources []event.Source
	fdsrc   map[int]event.Source
	efd     int
	timeout int
}

var (
	SkipAllEvents = errors.New("skip all events")
)

func NewListener(timeout int) (*Listener, error) {
	fd, err := syscall.EpollCreate1(0)
	if err != nil {
		return nil, err
	}
	l := &Listener{
		efd:     fd,
		timeout: timeout,
		fdsrc:   make(map[int]event.Source),
	}
	return l, nil
}

func (l *Listener) Close() error {
	return syscall.Close(l.efd)
}

func (l *Listener) Add(source event.Source) error {
	ev := &syscall.EpollEvent{
		Events: syscall.EPOLLIN,
		Fd:     int32(source.Fd()),
	}
	_ = syscall.SetNonblock(source.Fd(), true)

	if err := syscall.EpollCtl(l.efd, syscall.EPOLL_CTL_ADD, source.Fd(), ev); err != nil {
		return fmt.Errorf("add event to epoll %v: %w", source.Fd(), err)
	}

	l.sources = append(l.sources, source)
	l.fdsrc[source.Fd()] = source
	return nil
}

func (l *Listener) Poll() ([]event.Event, error) {
	epev := make([]syscall.EpollEvent, len(l.sources))
	n, err := syscall.EpollWait(l.efd, epev, l.timeout)
	if err != nil {
		return nil, err
	}

	var events []event.Event

	for i := 0; i < n; i++ {
		src, ok := l.fdsrc[int(epev[i].Fd)]
		if ok {
			ev, err := src.Read()
			if err == nil {
				events = append(events, ev)
			}
		}
	}
	return events, nil
}

func (l *Listener) Sources() []event.Source {
	return l.sources
}
