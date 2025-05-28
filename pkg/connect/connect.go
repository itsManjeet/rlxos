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
	"errors"
	"net"
	"reflect"
	"sync"
	"sync/atomic"
)

type Connection struct {
	conn     net.Conn
	encoder  *json.Encoder
	decoder  *json.Decoder
	pending  sync.Map
	nextID   int64
	handler  reflect.Value
	sendLock sync.Mutex
}

func NewConnection(conn net.Conn, handler any) *Connection {
	c := &Connection{
		conn:    conn,
		encoder: json.NewEncoder(conn),
		decoder: json.NewDecoder(conn),
		handler: reflect.ValueOf(handler),
	}

	go c.readLoop()
	return c
}

func (c *Connection) readLoop() {
	for {
		var msg Message
		if err := c.decoder.Decode(&msg); err != nil {
			break
		}

		if msg.Method != "" {
			go c.handleRequest(msg)
		} else {
			if ch, ok := c.pending.Load(msg.ID); ok {
				ch.(chan Message) <- msg
				c.pending.Delete(msg.ID)
			}
		}
	}
}

func (c *Connection) handleRequest(msg Message) {
	method := c.handler.MethodByName(msg.Method)
	if !method.IsValid() {
		err := "unknown method"
		c.send(Message{ID: msg.ID, Error: &err})
		return
	}

	methodType := method.Type()
	if methodType.NumIn() != 1 {
		err := "method must take 1 argument"
		c.send(Message{ID: msg.ID, Error: &err})
		return
	}

	argType := methodType.In(0)
	argPtr := reflect.New(argType)

	if err := json.Unmarshal(msg.Parameters, argPtr.Interface()); err != nil {
		err := "invalid parameters: " + err.Error()
		c.send(Message{ID: msg.ID, Error: &err})
		return
	}

	if methodType.NumOut() != 2 {
		err := "method must return 2 argument"
		c.send(Message{ID: msg.ID, Error: &err})
		return
	}

	results := method.Call([]reflect.Value{argPtr.Elem()})
	var (
		result any
		errstr *string
	)

	errVal := results[1]
	if !errVal.IsNil() {
		e := errVal.Interface().(error).Error()
		errstr = &e
	} else {
		result = results[0].Interface()
	}

	if errstr != nil {
		c.send(Message{
			ID:    msg.ID,
			Error: errstr,
		})
	}

	data, err := json.Marshal(result)
	if err != nil {
		err := "failed to marshal result: " + err.Error()
		c.send(Message{ID: msg.ID, Error: &err})
		return
	}

	c.send(Message{
		ID:     msg.ID,
		Result: data,
	})
}

func (c *Connection) send(msg Message) error {
	c.sendLock.Lock()
	defer c.sendLock.Unlock()

	return c.encoder.Encode(msg)
}

func (c *Connection) Call(method string, params, result any) error {
	id := atomic.AddInt64(&c.nextID, 1)
	msg := Message{ID: id, Method: method}
	msg.Parameters, _ = json.Marshal(params)

	ch := make(chan Message, 1)
	c.pending.Store(id, ch)
	c.send(msg)

	resp := <-ch
	if resp.Error != nil {
		return errors.New(*resp.Error)
	}
	return json.Unmarshal(resp.Result, result)
}
