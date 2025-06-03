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

	"rlxos.dev/pkg/graphics"
	"rlxos.dev/pkg/graphics/canvas"
)

type Switcher struct {
	graphics.Label
	TotalWorkspaces int
	ActiveWorkspace int
}

func (c *Switcher) String() string {
	return "[SWITCHER(" + c.Text + ")]"
}

func (c *Switcher) Draw(canvas canvas.Canvas) {
	c.Label.Text = ""
	for i := range c.TotalWorkspaces {
		s := "   "
		if i == c.ActiveWorkspace {
			s = "  •"
		}
		c.Label.Text += fmt.Sprintf("%s%v", s, i+1)
	}
	c.Label.Draw(canvas)
}
