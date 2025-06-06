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
	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/key"
)

type Entry struct {
	Label
}

func (e *Entry) Update(ev event.Event) {
	switch ev := ev.(type) {
	case key.Event:
		if ev.State == key.Pressed {
			switch ev.Key {
			case key.KEY_ENTER:
			case key.KEY_BACKSPACE:
				if len(e.Text) > 0 {
					e.Text = e.Text[:len(e.Text)-1]
					e.SetDirty(true)
				}
			case key.KEY_SPACE:
				e.Text += " "
				e.SetDirty(true)
			default:
				if k, ok := key.ToAscii[ev.Key]; ok {
					e.Text += string(k)
					e.SetDirty(true)
				}
			}
		}
	}
}
