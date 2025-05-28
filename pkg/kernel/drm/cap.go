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

package drm

import (
	"unsafe"

	"rlxos.dev/pkg/kernel/ioctl"
)

const (
	CapDumbBuffer uint64 = iota + 1
	CapVBlankHighCRTC
	CapDumbPreferredDepth
	CapDumbPreferShadow
	CapPrime
	CapTimestampMonotonic
	CapAsyncPageFlip
	CapCursorWidth
	CapCursorHeight

	CapAddFB2Modifiers = 0x10
)

type capability struct {
	id    uint64
	value uint64
}

func (c *Card) Support(cap uint64) bool {
	cap, err := c.Capability(cap)
	if err != nil {
		return false
	}
	return cap != 0
}

func (c *Card) Capability(id uint64) (uint64, error) {
	var cap capability
	cap.id = id
	if err := ioctl.Call(uintptr(c.fd), uintptr(IoctlGetCapability), unsafe.Pointer(&cap)); err != nil {
		return 0, err
	}
	return cap.value, nil
}
