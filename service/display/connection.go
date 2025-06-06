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
	"image"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/event"
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
	case "add-window":
		var rect image.Rectangle
		if err := json.Unmarshal(buf, &rect); err != nil {
			return nil, err
		}
		return AddWindow{
			rect:       rect,
			connection: c,
		}, nil

	case "damage":
		var rect image.Rectangle
		if err := json.Unmarshal(buf, &rect); err != nil {
			return nil, err
		}
		return Damage{
			rect: rect,
		}, nil
	}
	return nil, nil
}
