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

package shm

import (
	"syscall"
	"unsafe"
)

const (
	IPC_CREAT   = 01000
	IPC_EXCL    = 02000
	IPC_NOWAIT  = 04000
	IPC_PRIVATE = 0

	SHM_RDONLY = 010000
	SHM_RND    = 020000
	SHM_REMAP  = 040000
	SHM_EXEC   = 0100000

	SHM_LOCK   = 1
	SHM_UNLOCK = 12

	IPC_RMID = 0
	IPC_SET  = 1
	IPC_STAT = 2
)

type Memory int

func Get(key, size, flags int) (Memory, error) {
	id, _, err := syscall.Syscall(syscall.SYS_SHMGET, uintptr(key), uintptr(size), uintptr(flags))
	if err != 0 {
		return -1, err
	}
	return Memory(id), nil
}

func (m Memory) Control(cmd int) (*Info, error) {
	var info Info
	_, _, errno := syscall.Syscall(syscall.SYS_SHMCTL, uintptr(m), uintptr(cmd), uintptr(unsafe.Pointer(&info)))
	if errno != 0 {
		return nil, errno
	}
	return &info, nil
}

func (m Memory) Attach(addr uintptr, flags int) ([]byte, error) {
	addr, _, err := syscall.Syscall(syscall.SYS_SHMAT, uintptr(m), addr, uintptr(flags))
	if err != 0 {
		return nil, err
	}

	ptr := unsafe.Pointer(addr)

	if mInfo, err := m.Control(2); err != nil {
		return nil, err
	} else {
		return unsafe.Slice((*byte)(ptr), mInfo.SegmentSize), nil
	}
}

func (m Memory) Detach(data []byte) error {
	_, _, err := syscall.Syscall(syscall.SYS_SHMDT, uintptr(unsafe.Pointer(&data[0])), 0, 0)
	if err != 0 {
		return err
	}
	return nil
}

func (m Memory) Remove() error {
	_, err := m.Control(10)
	return err
}
