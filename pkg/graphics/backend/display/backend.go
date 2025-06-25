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

package display

import (
	"fmt"
	"image"
	"log"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/poll"
	"rlxos.dev/pkg/kernel/shm"
	"rlxos.dev/service/display/surface"
)

type Backend struct {
	poll *poll.Listener
	conn *connect.Connection
	img  *shm.Image
}

func (b *Backend) Init() (err error) {
	b.poll, err = poll.NewListener(-1)
	if err != nil {
		return fmt.Errorf("failed to setup poll: %v", err)
	}

	b.conn, err = connect.Connect("display")
	if err != nil {
		return fmt.Errorf("failed to connect to display: %v", err)
	}

	if err := b.poll.Add(&Connection{b.conn}); err != nil {
		return fmt.Errorf("failed to add connection to display: %v", err)
	}

	ev := surface.Create{
		Rect: image.Rect(0, 0, 800, 600),
	}

	var r surface.Created
	if err := b.conn.Send("surface.Create", ev, &r); err != nil {
		_ = b.conn.Close()
		return err
	}

	b.img, err = r.Image()
	if err != nil {
		_ = b.conn.Close()
		return err
	}
	return nil
}

func (b *Backend) Terminate() {
	_ = b.conn.Close()
}

func (b *Backend) PollEvents() ([]event.Event, error) {
	events, err := b.poll.Poll()
	if err != nil {
		return nil, err
	}
	for _, ev := range events {
		switch ev := ev.(type) {
		case surface.Resize:
			log.Printf("Got resize event %v", ev)
			b.img, err = ev.Image()
			if err != nil {
				log.Printf("failed to attach image: %v", err)
				return nil, err
			}
			log.Printf("resizing surface: %v", b.img.Bounds())
		}
	}
	return events, nil
}

func (b *Backend) Canvas() canvas.Canvas {
	return b.img
}

func (b *Backend) Update() {
	d := surface.Damage{
		Id:   b.img.Key(),
		Rect: b.img.Bounds(),
	}

	if err := b.conn.Send("surface.Damage", d, nil); err != nil {
		log.Println("failed send damage call", err)
	}
}

func (b *Backend) Listen(source event.Source) error {
	return b.poll.Add(source)
}
