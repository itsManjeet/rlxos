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

package vt

import (
	"fmt"
	"os"
	"os/exec"
	"syscall"
	"unsafe"

	"rlxos.dev/pkg/kernel/ioctl"
)

type VT struct {
	ptmx *os.File
	pts  *os.File
}

func Open() (*VT, error) {
	ptmx, err := os.OpenFile("/dev/ptmx", os.O_RDWR|syscall.O_CLOEXEC, 0)
	if err != nil {
		return nil, fmt.Errorf("open ptmx: %v", err)
	}

	if err := ioctl.Call(ptmx.Fd(), syscall.TIOCSPTLCK, uintptr(unsafe.Pointer(&[]int32{0}[0]))); err != nil {
		_ = ptmx.Close()
		return nil, err
	}

	val := 0
	if err := ioctl.Call(ptmx.Fd(), syscall.TIOCSPTLCK, uintptr(unsafe.Pointer(&val))); err != nil {
		_ = ptmx.Close()
		return nil, err
	}

	var n uint32

	if err := ioctl.Call(ptmx.Fd(), syscall.TIOCGPTN, uintptr(unsafe.Pointer(&n))); err != nil {
		_ = ptmx.Close()
		return nil, fmt.Errorf("ptsname failed: %v", err)
	}

	pts, err := os.OpenFile(fmt.Sprintf("/dev/pts/%d", n), os.O_RDWR, 0)
	if err != nil {
		_ = ptmx.Close()
		return nil, err
	}

	return &VT{
		ptmx: ptmx,
		pts:  pts,
	}, nil
}

func (vt *VT) Start(cmd *exec.Cmd) error {
	cmd.Stdin = vt.pts
	cmd.Stdout = vt.pts
	cmd.Stderr = vt.pts

	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.Setsid = true
	// cmd.SysProcAttr.Setctty = true
	// cmd.SysProcAttr.Ctty = int(vt.pts.Fd())

	if err := cmd.Start(); err != nil {
		return err
	}

	return nil
}

func (vt *VT) Read(buf []byte) (int, error) {
	return vt.ptmx.Read(buf)
}

func (vt *VT) Write(buf []byte) (int, error) {
	return vt.ptmx.Write(buf)
}

func (vt *VT) Fd() int {
	return int(vt.ptmx.Fd())
}

func (vt *VT) Resize(rows, cols uint16) error {
	var size struct {
		Rows uint16
		Cols uint16
		X, Y uint16
	}
	size.Rows = rows
	size.Cols = cols

	return ioctl.Call(vt.pts.Fd(), syscall.TIOCSWINSZ, unsafe.Pointer(&size))
}
