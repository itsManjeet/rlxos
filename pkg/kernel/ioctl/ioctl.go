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

package ioctl

import (
	"fmt"
	"os"
	"syscall"
	"unsafe"
)

const (
	NONE         = 0x0
	WRITE        = 0x1
	READ         = 0x2
	NRBITS       = 8
	TYPEBITS     = 8
	SIZEBITS     = 14
	DIRBITS      = 2
	NRSHIFT      = 0
	NRMASK       = (1 << NRBITS) - 1
	TYPEMASK     = (1 << TYPEBITS) - 1
	SIZEMASK     = (1 << SIZEBITS) - 1
	DIRMASK      = (1 << DIRBITS) - 1
	TYPESHIFT    = NRSHIFT + NRBITS
	SIZESHIFT    = TYPESHIFT + TYPEBITS
	DIRSHIFT     = SIZESHIFT + SIZEBITS
	IN           = WRITE << DIRSHIFT
	OUT          = READ << DIRSHIFT
	INOUT        = (WRITE | READ) << DIRSHIFT
	IOCSIZE_MASK = SIZEMASK << SIZESHIFT
)

func IOC(dir, t, nr, size int) int {
	return (dir << DIRSHIFT) | (t << TYPESHIFT) |
		(nr << NRSHIFT) | (size << SIZESHIFT)
}

func IO(t, nr int) int {
	return IOC(NONE, t, nr, 0)
}

func IOR(t, nr, size int) int {
	return IOC(READ, t, nr, size)
}

func IOW(t, nr, size int) int {
	return IOC(WRITE, t, nr, size)
}

func IOWR(t, nr, size int) int {
	return IOC(READ|WRITE, t, nr, size)
}

func DIR(nr int) int {
	return ((nr) >> DIRSHIFT) & DIRMASK
}

func TYPE(nr int) int {
	return ((nr) >> TYPESHIFT) & TYPEMASK
}

func NR(nr int) int {
	return ((nr) >> NRSHIFT) & NRMASK
}

func SIZE(nr int) int {
	return ((nr) >> SIZESHIFT) & SIZEMASK
}

func Call(fd, cmd uintptr, arg interface{}) error {
	var v uintptr
	switch arg := arg.(type) {
	case unsafe.Pointer:
		v = uintptr(arg)
	case int:
		v = uintptr(arg)
	case uintptr:
		v = arg
	default:
		return fmt.Errorf("ioctl: invalid argument")
	}
	if _, _, err := syscall.Syscall(syscall.SYS_IOCTL, fd, cmd, v); err != 0 {
		return &os.SyscallError{
			Syscall: "SYSIOCTL",
			Err:     err,
		}
	}
	return nil
}
