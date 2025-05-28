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

type Permission struct {
	Key        int32
	UID, GID   uint32
	CUID, CGID uint32
	Mode       uint16
	padding    [26]byte
}

type Info struct {
	Permission    Permission
	SegmentSize   uint64
	AttachTime    int64
	DetachTime    int64
	ChangeTime    int64
	CPID          int32
	LastPid       int32
	TotalAttached uint64
	padding       [2]uint64
}
