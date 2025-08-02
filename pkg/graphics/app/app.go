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
	"time"

	"rlxos.dev/pkg/event/life"
	"rlxos.dev/pkg/event/resize"
	"rlxos.dev/pkg/graphics/backend"
	"rlxos.dev/pkg/graphics/style"
	"rlxos.dev/pkg/graphics/widget"
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

func Run(w widget.Widget) error {
	if bk == nil {
		return fmt.Errorf("no supported backend found")
	}

	if err := bk.Init(); err != nil {
		return err
	}
	defer bk.Terminate()

	w.Construct()
	w.OnStyleChange(style.Default)

	{
		// Initial draw
		canvas := bk.Canvas()
		w.SetDirty(true)

		w.SetBounds(canvas.Bounds())

		w.Draw(canvas)
		bk.Update()
	}

	for {
		events, err := bk.PollEvents()
		if err == nil {
			for _, event := range events {
				switch event.(type) {
				case resize.Event:
					w.SetDirty(true)
				case life.End:
					w.Destroy()
					return nil
				}
				w.Update(event)
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
}
