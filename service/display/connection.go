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
	"encoding/json"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/event"
	"rlxos.dev/service/display/surface"
)

type Connection struct {
	*connect.Connection
}

func (c *Connection) Read() (event.Event, error) {
	cmd, buf, err := c.Receive()
	if err != nil {
		return nil, err
	}

	switch cmd {
	case "surface.Create":
		var e surface.Create
		if err := json.Unmarshal(buf, &e); err != nil {
			return nil, err
		}
		return SurfaceEvent{
			conn:  c.Connection,
			event: e,
		}, nil

	case "surface.Damage":
		var d surface.Damage
		if err := json.Unmarshal(buf, &d); err != nil {
			return nil, err
		}
		return SurfaceEvent{
			conn:  c.Connection,
			event: d,
		}, nil
	}
	return nil, nil
}
