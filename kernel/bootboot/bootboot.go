/*
 * mykernel/go/bootboot/bootboot.go
 *
 * Copyright (C) 2017 - 2021 bzt (bztsrc@gitlab)
 * Copyright (C) 2023 TotallyGamerJet (rewrite for standard go toolchain)

 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 * This file is part of the BOOTBOOT Protocol package.
 * @brief Go architecture independent part of the bootboot structure
 *
 */
package bootboot

import "unsafe"

const (
	Magic = 0x544F4F42 // "BOOT"

	MMIO = 0xFFFFFFFFF8000000
	FB   = 0xFFFFFFFFFC000000
	INFO = 0xFFFFFFFFFFE00000
	ENV  = 0xFFFFFFFFFFE01000
	CORE = 0xFFFFFFFFFFE02000

	ProtocolMinimal   = 0
	ProtocolStatic    = 1
	ProtocolDynamic   = 2
	ProtocolBigendian = 128

	BIOS     = 0
	UEFI     = 4
	RPI      = 8
	COREBOOT = 12

	ARGB = 0
	RGBA = 1
	ABGR = 2
	BGRA = 3

	MmapUsed = 0 /* don't use. Reserved or unknown regions */
	MmapFree = 1 /* usable memory */
	MmapAcpi = 2 /* acpi memory, volatile and non-volatile as well */
	MmapMmio = 3 /* memory mapped IO region */

	InitrdMaxsize = 16 /* Mb */
)

// MMapEnt stores in least significant tetrad (half byte) of size
// this means size described in 16 byte units (not a problem, most modern
// firmware report memory in pages, 4096 byte units anyway).
type MMapEnt struct {
	Ptr   uint64
	_size uint64
}

func (e *MMapEnt) Size() uint64 {
	return e._size & 0xFFFFFFFFFFFFFFF0
}

func (e *MMapEnt) Type() uint64 {
	return e._size & 0xF
}

func (e *MMapEnt) IsFree() bool {
	return e._size&0xF == 1
}

type BOOTBOOT struct {
	Magic      uint32   /* 'BOOT' magic */
	Size       uint32   /* length of bootboot structure, minimum 128 */
	Protocol   uint8    /* 1, static addresses, see PROTOCOL_* and LOADER_* above */
	FbType     uint8    /* framebuffer type, see FB_* above */
	Numcores   uint16   /* number of processor cores */
	Bspid      uint16   /* Bootstrap processor ID (Local APIC Id on x86_64) */
	Timezone   int16    /* in minutes -1440..1440 */
	Datetime   [8]uint8 /* in BCD yyyymmddhhiiss UTC (independent to timezone) */
	InitrdPtr  uint64   /* ramdisk image position and size */
	InitrdSize uint64
	FbPtr      uint64 /* framebuffer pointer and dimensions */
	FbSize     uint32
	FbWidth    uint32
	FbHeight   uint32
	FbScanline uint32
	Arch       arch /* the rest (64 bytes) is platform specific */
	/* use like this:
	 * MMapEnt *mmap_ent = &bootboot.mmap; mmap_ent++;
	 * until you reach bootboot->size, while(mmap_ent < bootboot + bootboot->size) */
	Mmap MMapEnt
}

// This function doesn't get compiled into the final binary but is a compile time
// check to make sure that the Mmap field is at the 128th byte of the struct if not
// the compiler will fail.
// This is necessary because Go doesn't have a packed pragma (yet? golang/go#36606)
// and so this exists as a sanity check to make sure nothing strange has happened.
func _() {
	var x [1]byte
	_ = x[unsafe.Offsetof(BOOTBOOT{}.Mmap)-128]
}
