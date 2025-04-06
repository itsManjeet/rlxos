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
	"fmt"
	"log"

	"rlxos.dev/pkg/graphics/app"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/event"
)

type UiTest struct {
	app.Application

	eventString string
}

func (u *UiTest) Draw(c canvas.Canvas) {
	width, height := c.Size()
	c.DrawRectangle(0, 0, width, height)
	c.DrawText(u.eventString, width/2, height/2, true)
}

func (u *UiTest) Update(e event.Event) {
	switch e := e.(type) {
	case event.Keyboard:
		u.eventString = fmt.Sprintf("Keyboard Event '%c' %d", e.Key, e.Rune)
	case event.Mouse:
		u.eventString = fmt.Sprintf("Mouse Event: %d,%d (%d %v)", e.X, e.Y, e.Button, e.Pressed)
	}
}

func main() {
	if err := app.Run(&UiTest{}); err != nil {
		log.Fatal(err)
	}
}
