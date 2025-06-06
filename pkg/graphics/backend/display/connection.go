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
	"encoding/json"

	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/event"
	"rlxos.dev/pkg/event/button"
	"rlxos.dev/pkg/event/cursor"
	"rlxos.dev/pkg/event/key"
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
	case "key-event":
		var k key.Event
		if err := json.Unmarshal(buf, &k); err != nil {
			return nil, err
		}
		return k, nil
	case "button-event":
		var k button.Event
		if err := json.Unmarshal(buf, &k); err != nil {
			return nil, err
		}
		return k, nil
	case "cursor-event":
		var k cursor.Event
		if err := json.Unmarshal(buf, &k); err != nil {
			return nil, err
		}
		return k, nil
	}
	return nil, nil
}
