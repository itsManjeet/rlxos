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

package app

import (
	"fmt"
	"image"
	"time"

	"rlxos.dev/pkg/event/life"
	"rlxos.dev/pkg/event/resize"
	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/backend"
)

var (
	bk backend.Backend
)

func SetBackend(b backend.Backend) {
	bk = b
}

func Backend() backend.Backend {
	return bk
}

type Init interface {
	Init(rect image.Rectangle) error
}

func Run(w graphics.Widget) error {
	if bk == nil {
		return fmt.Errorf("no supported backend found")
	}

	if err := bk.Init(); err != nil {
		return err
	}
	defer bk.Terminate()

	{
		// Initial draw
		canvas := bk.Canvas()
		if i, ok := w.(Init); ok {
			if err := i.Init(canvas.Bounds()); err != nil {
				return err
			}
		}
		w.SetDirty(true)
		w.SetBounds(canvas.Bounds())
		w.Draw(canvas)
		bk.Update()
	}

	if u, ok := w.(graphics.Updatable); ok {
		for {
			events, err := bk.PollEvents()
			if err == nil {
				for _, event := range events {
					switch event.(type) {
					case resize.Event:
						w.SetDirty(true)
					case life.End:
						// TODO: widget destroy
						return nil
					}
					u.Update(event)
				}
			}

			canvas := bk.Canvas()
			w.SetBounds(canvas.Bounds())

			if w.Dirty() {
				w.Draw(canvas)
				w.SetDirty(false)
				bk.Update()
			} else {
				time.Sleep(16 * time.Millisecond)
			}
		}
	} else {
		for {
			time.Sleep(time.Hour * 9999)
		}
	}
}
