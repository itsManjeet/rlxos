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
	"image"
	"image/draw"
	"math/rand"

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/kernel/input"
)

type Display struct {
	graphics.BaseWidget

	Taskbar         Taskbar
	Workspaces      []Workspace
	activeWorkspace int
	cursor          image.Point
	keys            map[int]bool
}

func (d *Display) Update(event input.Event) {
	if d.keys == nil {
		d.keys = map[int]bool{}
	}
	switch event := event.(type) {
	case input.CursorEvent:
		if event.Absolute {
			if event.X != 0 {
				d.cursor.X = event.X
			}

			if event.Y != 0 {
				d.cursor.Y = event.Y
			}
		} else {
			d.cursor.X += event.X
			d.cursor.Y += event.Y
		}
		d.SetDirty(true)
	case input.KeyEvent:
		if d.isKeySet(input.KEY_LEFTALT) && event.Pressed {
			switch event.Code {
			case input.KEY_ENTER:
				d.Workspaces[d.activeWorkspace].addWindow("Window")
				return

			case input.KEY_TAB:
				if len(d.Workspaces[d.activeWorkspace].Children()) > 1 {
					win := d.Workspaces[d.activeWorkspace].Children()[0].(*Window)
					d.Workspaces[d.activeWorkspace].Remove(0)
					d.Workspaces[d.activeWorkspace].Raise(win)
				}
				return

			case input.KEY_R:
				d.cursor.X = d.Bounds().Dx() / 2
				d.cursor.Y = d.Bounds().Dy() / 2
				d.Taskbar.Status.Send("Reseting cursor")
				d.BaseWidget.SetDirty(true)
				return

			case input.KEY_S:
				d.activeWorkspace = (d.activeWorkspace + 1) % len(d.Workspaces)
				d.Taskbar.Switcher.ActiveWorkspace = d.activeWorkspace
				d.Taskbar.Switcher.SetDirty(true)
				d.Workspaces[d.activeWorkspace].SetDirty(true)
				return

			case input.KEY_UP:
				if d.Workspaces[d.activeWorkspace].activeWindow != nil {
					rect := d.Workspaces[d.activeWorkspace].activeWindow.Bounds()
					if d.isKeySet(input.KEY_LEFTSHIFT) {
						rect.Max.Y -= 10
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect)
					} else {
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect.Add(image.Pt(0, -10)))
					}
				}
				return

			case input.KEY_DOWN:
				if d.Workspaces[d.activeWorkspace].activeWindow != nil {
					rect := d.Workspaces[d.activeWorkspace].activeWindow.Bounds()
					if d.isKeySet(input.KEY_LEFTSHIFT) {
						rect.Max.Y += 10
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect)
					} else {
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect.Add(image.Pt(0, 10)))
					}
				}
				return

			case input.KEY_LEFT:
				if d.Workspaces[d.activeWorkspace].activeWindow != nil {
					rect := d.Workspaces[d.activeWorkspace].activeWindow.Bounds()
					if d.isKeySet(input.KEY_LEFTSHIFT) {
						rect.Max.X -= 10
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect)
					} else {
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect.Add(image.Pt(-10, 0)))
					}
				}
				return

			case input.KEY_RIGHT:
				if d.Workspaces[d.activeWorkspace].activeWindow != nil {
					rect := d.Workspaces[d.activeWorkspace].activeWindow.Bounds()
					if d.isKeySet(input.KEY_LEFTSHIFT) {
						rect.Max.X += 10
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect)
					} else {
						d.Workspaces[d.activeWorkspace].activeWindow.SetBounds(rect.Add(image.Pt(10, 0)))
					}
				}
				return
			}
		}
		d.keys[event.Code] = event.Pressed
	}

	d.Workspaces[d.activeWorkspace].Update(event)
	d.Taskbar.Update(event)
}

func (d *Display) Draw(canvas canvas.Canvas) {
	if d.Taskbar.Dirty() {
		d.Taskbar.Draw(canvas)
		d.Taskbar.SetDirty(false)
	}

	if d.Workspaces[d.activeWorkspace].Dirty() {
		d.Workspaces[d.activeWorkspace].Draw(canvas)
		d.Workspaces[d.activeWorkspace].SetDirty(false)
	}

	draw.Draw(canvas, image.Rect(d.cursor.X, d.cursor.Y, d.cursor.X+2, d.cursor.Y+2), image.NewUniform(graphics.ColorBlack), image.Point{}, draw.Src)
}

func (d *Display) SetBounds(rect image.Rectangle) {
	d.BaseWidget.SetBounds(rect)

	d.Taskbar.SetBounds(image.Rect(rect.Min.X, rect.Min.Y, rect.Max.X, rect.Min.Y+d.Taskbar.Height))
	d.Workspaces[d.activeWorkspace].SetBounds(image.Rect(rect.Min.X, rect.Min.Y+d.Taskbar.Height, rect.Max.X, rect.Max.Y))
}

func (d *Display) SetDirty(b bool) {
	d.BaseWidget.SetDirty(b)

	d.Taskbar.SetDirty(b)
	d.Workspaces[d.activeWorkspace].SetDirty(b)
}

func (d *Display) Dirty() bool {
	return d.Taskbar.Dirty() || d.Workspaces[d.activeWorkspace].Dirty() || d.BaseWidget.Dirty()
}

func pos(w, h int, rect image.Rectangle) image.Rectangle {
	maxX := rect.Max.X - w
	maxY := rect.Max.Y - h
	if maxX < 0 || maxY < 0 {
		return image.Rect(0, 0, 0, 0)
	}
	x := rand.Intn(maxX+1-rect.Min.X) + rect.Min.X
	y := rand.Intn(maxY+1-rect.Min.Y) + rect.Min.Y
	return image.Rect(x, y, x+w, y+h)
}

func (d *Display) isKeySet(key int) bool {
	if d.keys != nil {
		if status, ok := d.keys[key]; ok {
			return status
		}
	}
	return false
}
