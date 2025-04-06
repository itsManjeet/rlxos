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

package uevent

import (
	"fmt"
	"os"
	"syscall"
)

func Listen(f func(*UEvent)) error {
	socket, err := syscall.Socket(syscall.AF_NETLINK, syscall.SOCK_RAW, syscall.NETLINK_KOBJECT_UEVENT)
	if err != nil {
		return fmt.Errorf("failed to create socket: %v", err)
	}
	defer syscall.Close(socket)

	if err := syscall.Bind(socket, &syscall.SockaddrNetlink{
		Family: syscall.AF_NETLINK,
		Pid:    uint32(os.Getpid()),
		Groups: 0xFFFFFFFF,
	}); err != nil {
		return fmt.Errorf("failed to bind to socket: %v", err)
	}

	buffer := make([]byte, BUFFER_SIZE)

	for {
		len, _, err := syscall.Recvfrom(socket, buffer, 0)
		if err != nil {
			continue
		}

		u, err := parseUEvent(buffer, len)
		if err != nil {
			continue
		}
		go f(u)
	}
}
