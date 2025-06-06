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

package connect

import (
	"encoding/json"
	"fmt"
	"net"
	"reflect"
)

type Connection struct {
	conn net.Conn
}

type transaction struct {
	Type    string          `json:"type,omitempty"`
	Payload json.RawMessage `json:"payload,omitempty"`
}

func Connect(id string) (*Connection, error) {
	conn, err := net.Dial(AddrOf(id))
	if err != nil {
		return nil, fmt.Errorf("failed to connect to %s, %v", id, err)
	}

	return &Connection{
		conn: conn,
	}, nil
}

func (c *Connection) Close() error {
	return c.conn.Close()
}

func (c *Connection) Send(cmd string, payload, reply any) error {
	encoder := json.NewEncoder(c.conn)

	p, err := json.Marshal(payload)
	if err != nil {
		return err
	}

	if err := encoder.Encode(&transaction{
		Type:    cmd,
		Payload: p,
	}); err != nil {
		return err
	}

	if reply != nil {
		_, buf, err := c.Receive()
		if err != nil {
			return err
		}
		if err := json.Unmarshal(buf, &reply); err != nil {
			return err
		}
	}
	return nil
}

func (c *Connection) Receive() (string, []byte, error) {
	decoder := json.NewDecoder(c.conn)
	var t transaction
	if err := decoder.Decode(&t); err != nil {
		return "", nil, err
	}

	return t.Type, t.Payload, nil
}

func (c *Connection) Fd() int {
	v := reflect.Indirect(reflect.ValueOf(c.conn))
	conn := v.FieldByName("conn")
	netFd := reflect.Indirect(conn.FieldByName("fd"))
	pfd := netFd.FieldByName("pfd")
	fd := int(pfd.FieldByName("Sysfd").Int())
	return fd
}
