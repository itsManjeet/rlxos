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
	"log"
	"net"
	"os"
	"path/filepath"
	"testing"
	"time"
)

type EchoServer struct {
}

func (e *EchoServer) Echo(msg string) (string, error) {
	return "You echoed: " + msg, nil
}

func TestConnection(t *testing.T) {
	socketPath := filepath.Join(os.TempDir(), "connect.sock")
	defer os.Remove(socketPath)

	os.Remove(socketPath)

	// server
	go func() {
		l, err := net.Listen("unix", socketPath)
		if err != nil {
			log.Fatalf("server listen failed: %v", err)
		}
		defer l.Close()

		for {
			conn, err := l.Accept()
			if err != nil {
				continue
			}

			NewConnection(conn, &EchoServer{})
		}
	}()

	time.Sleep(100 * time.Millisecond)

	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		t.Fatalf("client dial failed: %v", err)
	}
	c := NewConnection(conn, nil)

	var resp string
	if err := c.Call("Echo", "test message", &resp); err != nil {
		t.Errorf("echo failed: %v", err)
	}

	if resp != "You echoed: test message" {
		t.Errorf("unexpected echo result: %s", resp)
	}
}
