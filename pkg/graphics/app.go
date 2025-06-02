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

package graphics

import (
	"time"

	"rlxos.dev/pkg/graphics/backend"
)

func Run(w Widget, bs ...backend.Backend) error {
	if bs == nil {
		bs = defaultBackends
	}

	var sb backend.Backend
	for _, b := range bs {
		if err := b.Init(); err == nil {
			sb = b
			break
		}
	}
	defer sb.Terminate()

	w.SetDirty(true)

	tick := time.Now()

	for {
		for _, event := range sb.PollEvents() {
			switch event := event.(type) {
			default:
				if u, ok := w.(Updatable); ok {
					u.Update(event)
				}
			}
		}

		if elapsed := time.Since(tick); elapsed.Milliseconds() >= 16 {
			tick = time.Now()
			if u, ok := w.(Updatable); ok {
				u.Update(tick)
			}
		}

		canvas := sb.Canvas()
		w.SetBounds(canvas.Bounds())

		if w.Dirty() {
			w.Draw(canvas)
			w.SetDirty(false)
		}
		sb.Update()

	}
}
