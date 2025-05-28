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
	"flag"
	"log"
	"os"
	"syscall"

	"rlxos.dev/pkg/pool"
)

const (
	BUFFER_SIZE = 2048
)

var (
	parallel  int
	eventPool *pool.Pool
)

func init() {
	flag.IntVar(&parallel, "parallel", 10, "Run jobs in parallel")
}

func main() {
	flag.Parse()

	eventPool = pool.CreatePool(parallel)
	eventPool.Start()

	socket, err := syscall.Socket(syscall.AF_NETLINK, syscall.SOCK_RAW, syscall.NETLINK_KOBJECT_UEVENT)
	if err != nil {
		log.Fatalf("failed to create socket: %v", err)
	}
	defer syscall.Close(socket)

	if err := syscall.Bind(socket, &syscall.SockaddrNetlink{
		Family: syscall.AF_NETLINK,
		Pid:    uint32(os.Getpid()),
		Groups: 0xFFFFFFFF,
	}); err != nil {
		log.Fatalf("failed to bind to socket: %v", err)
	}

	buffer := make([]byte, BUFFER_SIZE)

	for {
		len, _, err := syscall.Recvfrom(socket, buffer, 0)
		if err != nil {
			continue
		}
		go eventPool.Submit(parseEvent(buffer, len))
	}
}
