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
	"fmt"
	"log"
	"net"
	"os"
	"path/filepath"
)

func AddrOf(id string) (string, string) {
	return "unix", filepath.Join("/cache/services", id)
}

type Server interface {
	Handle(client *Connection)
}

func Listen(id string, s Server) error {
	network, addr := AddrOf(id)
	_ = os.RemoveAll(addr)

	l, err := net.Listen(network, addr)
	if err != nil {
		return fmt.Errorf("failed to listen: %v", err)
	}

	for {
		conn, err := l.Accept()
		if err != nil {
			log.Printf("failed to accept connection: %v", err)
			continue
		}

		s.Handle(&Connection{conn: conn})
	}
}
