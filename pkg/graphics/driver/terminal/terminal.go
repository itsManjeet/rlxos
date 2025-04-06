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

package terminal

import (
	"fmt"
	"log"
	"os"
	"syscall"
	"unsafe"

	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/event"
)

type Driver struct {
	Display *os.File

	buffer        []rune
	width, height int
	o             syscall.Termios
}

func (d *Driver) Init() error {
	if d.Display == nil {
		d.Display = os.Stdout
	}

	_, _, err := syscall.Syscall(syscall.SYS_IOCTL, d.Display.Fd(), uintptr(syscall.TCGETS), uintptr(unsafe.Pointer(&d.o)))
	if err != 0 {
		return err
	}

	var size struct {
		Row     uint16
		Col     uint16
		XPixels uint16
		YPixels uint16
	}

	_, _, err = syscall.Syscall(syscall.SYS_IOCTL, d.Display.Fd(), 0x5413, uintptr(unsafe.Pointer(&size)))
	if err != 0 {
		return err
	}
	d.width = int(size.Col)
	d.height = int(size.Row)

	d.buffer = make([]rune, d.width*d.height)

	// _ = syscall.SetNonblock(int(d.Display.Fd()), true)

	raw := d.o
	raw.Iflag &^= syscall.ICRNL | syscall.IXON
	raw.Lflag &^= syscall.ECHO | syscall.ICANON | syscall.IEXTEN
	raw.Cc[syscall.VMIN] = 1
	raw.Cc[syscall.VTIME] = 0

	fmt.Fprint(d.Display, "\033[?25\033[?1000h")
	_, _, err = syscall.Syscall(syscall.SYS_IOCTL, d.Display.Fd(), uintptr(syscall.TCSETS), uintptr(unsafe.Pointer(&raw)))
	if err != 0 {
		return err
	}

	return nil
}

func (d *Driver) Destroy() {
	fmt.Fprint(d.Display, "\033[?25h\033[?1000l")
	_, _, err := syscall.Syscall(syscall.SYS_IOCTL, d.Display.Fd(), uintptr(syscall.TCSETS), uintptr(unsafe.Pointer(&d.o)))
	if err != 0 {
		log.Println("failed to restore terminal state", err)
	}
}

func (d *Driver) PollEvent() event.Event {
	buf := make([]byte, 6)
	n, err := d.Display.Read(buf)
	if err != nil || n == 0 {
		return err
	}

	if n >= 6 && buf[0] == 27 && buf[1] == '[' && buf[2] == 'M' {
		button := buf[3] - 32
		x := int(buf[4]-32) - 1
		y := int(buf[5]-32) - 1
		return event.Mouse{
			X: x, Y: y,
			Button:  int(button & 0x3),
			Pressed: (button & 0x3) == 0,
		}
	}

	if n >= 3 && buf[0] == 27 && buf[1] == '[' {
		switch buf[2] {
		case 'A':
			return event.Keyboard{Key: event.KeyUp}
		case 'B':
			return event.Keyboard{Key: event.KeyDown}
		case 'C':
			return event.Keyboard{Key: event.KeyRight}
		case 'D':
			return event.Keyboard{Key: event.KeyLeft}
		case 'H':
			return event.Keyboard{Key: event.KeyHome}
		case 'F':
			return event.Keyboard{Key: event.KeyEnd}
		}
	}

	if n >= 4 && buf[0] == 27 && buf[1] == '[' && buf[3] == '~' {
		switch buf[2] {
		case '1':
			return event.Keyboard{Key: event.KeyHome}
		// case '2':
		// 	return event.Keyboard{Key: event.KeyInsert}
		case '3':
			return event.Keyboard{Key: event.KeyDelete}
		case '4':
			return event.Keyboard{Key: event.KeyEnd}
		case '5':
			return event.Keyboard{Key: event.KeyPageUp}
		case '6':
			return event.Keyboard{Key: event.KeyPageDown}
		case '7':
			return event.Keyboard{Key: event.KeyHome}
		case '8':
			return event.Keyboard{Key: event.KeyEnd}
		}
	}

	if buf[0] == '\r' || buf[0] == '\n' {
		return event.Keyboard{Key: event.KeyEnter}
	}

	if buf[0] == 27 && n == 1 {
		return event.Keyboard{Key: event.KeyEscape}
	}

	if buf[0] == '\t' {
		return event.Keyboard{Key: event.KeyTab}
	}

	if buf[0] == 127 {
		return event.Keyboard{Key: event.KeyBackspace}
	}

	r := rune(buf[0])
	if r >= 32 && r <= 126 {
		return event.Keyboard{Key: event.KeyAscii, Rune: r}
	}

	return event.Keyboard{Key: event.KeyUnknown}
}

func (d *Driver) Canvas() canvas.Canvas {
	return d
}

func (d *Driver) Update() {
	fmt.Fprint(d.Display, "\033[H\033[J", string(d.buffer))
}
