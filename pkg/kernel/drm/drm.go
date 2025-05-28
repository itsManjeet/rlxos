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
	"log"
	"unsafe"

	"rlxos.dev/pkg/kernel/ioctl"
)

const (
	DisplayInfoLen   = 32
	ConnectorNameLen = 32
	DisplayModeLen   = 32
	PropNameLen      = 32

	Connected         = 1
	Disconnected      = 2
	UnknownConnection = 3
)

type (
	sysResources struct {
		fbIdPtr              uint64
		crtcIdPtr            uint64
		connectorIdPtr       uint64
		encoderIdPtr         uint64
		CountFbs             uint32
		CountCrtcs           uint32
		CountConnectors      uint32
		CountEncoders        uint32
		MinWidth, MaxWidth   uint32
		MinHeight, MaxHeight uint32
	}

	sysGetConnector struct {
		encodersPtr   uint64
		modesPtr      uint64
		propsPtr      uint64
		propValuesPtr uint64

		countModes    uint32
		countProps    uint32
		countEncoders uint32

		encoderID       uint32 // current encoder
		ID              uint32
		connectorType   uint32
		connectorTypeID uint32

		connection        uint32
		mmWidth, mmHeight uint32 // HxW in millimeters
		subpixel          uint32
		pad               uint32
	}

	sysGetEncoder struct {
		id  uint32
		typ uint32

		crtcID uint32

		possibleCrtcs  uint32
		possibleClones uint32
	}

	ModeInfo struct {
		Clock                                         uint32
		Hdisplay, HsyncStart, HsyncEnd, Htotal, Hskew uint16
		Vdisplay, VsyncStart, VsyncEnd, Vtotal, Vscan uint16

		Vrefresh uint32

		Flags uint32
		Type  uint32
		Name  [DisplayModeLen]uint8
	}

	Resources struct {
		sysResources

		Fbs        []uint32
		Crtcs      []uint32
		Connectors []uint32
		Encoders   []uint32
	}

	Connector struct {
		sysGetConnector

		ID            uint32
		EncoderID     uint32
		Type          uint32
		TypeID        uint32
		Connection    uint8
		Width, Height uint32
		Subpixel      uint8

		Modes []ModeInfo

		Props      []uint32
		PropValues []uint64

		Encoders []uint32
	}

	Encoder struct {
		ID   uint32
		Type uint32

		CrtcID uint32

		PossibleCrtcs  uint32
		PossibleClones uint32
	}

	sysCreateDumb struct {
		height, width uint32
		bpp           uint32
		flags         uint32

		// returned values
		handle uint32
		pitch  uint32
		size   uint64
	}

	sysMapDumb struct {
		handle uint32 // Handle for the object being mapped
		pad    uint32

		// Fake offset to use for subsequent mmap call
		// This is a fixed-size type for 32/64 compatibility.
		offset uint64
	}

	sysFBCmd struct {
		fbID          uint32
		width, height uint32
		pitch         uint32
		bpp           uint32
		depth         uint32

		/* driver specific handle */
		handle uint32
	}

	sysRmFB struct {
		handle uint32
	}

	sysCrtc struct {
		setConnectorsPtr uint64
		countConnectors  uint32

		id   uint32
		fbID uint32

		x, y uint32

		gammaSize uint32
		modeValid uint32
		modeInfo  ModeInfo
	}

	sysDestroyDumb struct {
		handle uint32
	}

	Crtc struct {
		ID       uint32
		BufferID uint32 // FB id to connect to 0 = disconnect

		X, Y          uint32 // Position on the framebuffer
		Width, Height uint32
		ModeValid     int
		ModeInfo      ModeInfo

		GammaSize int // Number of gamma stops
	}

	Framebuffer struct {
		Height, Width, BPP, Flags uint32
		Handle                    uint32
		Pitch                     uint32
		Size                      uint64
	}

	Modeset struct {
		Width, Height uint16

		ModeInfo  ModeInfo
		Connector uint32
		Crtc      uint32
	}
)

var (
	IoctlGetCapability     = ioctl.IOWR('d', 0x0c, int(unsafe.Sizeof(capability{})))
	IoctlResources         = ioctl.IOWR('d', 0xA0, int(unsafe.Sizeof(sysResources{})))
	IoctlGetCrtc           = ioctl.IOWR('d', 0xA1, int(unsafe.Sizeof(sysCrtc{})))
	IoctlSetCrtc           = ioctl.IOWR('d', 0xA2, int(unsafe.Sizeof(sysCrtc{})))
	IoctlGetEncoder        = ioctl.IOWR('d', 0xA6, int(unsafe.Sizeof(sysGetEncoder{})))
	IoctlGetConnector      = ioctl.IOWR('d', 0xA7, int(unsafe.Sizeof(sysGetConnector{})))
	IoctlAddFramebuffer    = ioctl.IOWR('d', 0xAE, int(unsafe.Sizeof(sysFBCmd{})))
	IoctlRemoveFramebuffer = ioctl.IOWR('d', 0xAF, int(unsafe.Sizeof(uint32(0))))
	IoctlCreateDumb        = ioctl.IOWR('d', 0xB2, int(unsafe.Sizeof(sysCreateDumb{})))
	IoctlMapDumb           = ioctl.IOWR('d', 0xB3, int(unsafe.Sizeof(sysMapDumb{})))
	IoctlDestroyDumb       = ioctl.IOWR('d', 0xB4, int(unsafe.Sizeof(sysDestroyDumb{})))
)

func (c *Card) GetResources() (*Resources, error) {
	mres := &sysResources{}
	if err := ioctl.Call(uintptr(c.fd), uintptr(IoctlResources), uintptr(unsafe.Pointer(mres))); err != nil {
		return nil, err
	}

	var fbids, crtcids, connectorids, encoderids []uint32

	if mres.CountFbs > 0 {
		fbids = make([]uint32, mres.CountFbs)
		mres.fbIdPtr = uint64(uintptr(unsafe.Pointer(&fbids[0])))
	}
	if mres.CountCrtcs > 0 {
		crtcids = make([]uint32, mres.CountCrtcs)
		mres.crtcIdPtr = uint64(uintptr(unsafe.Pointer(&crtcids[0])))
	}
	if mres.CountEncoders > 0 {
		encoderids = make([]uint32, mres.CountEncoders)
		mres.encoderIdPtr = uint64(uintptr(unsafe.Pointer(&encoderids[0])))
	}
	if mres.CountConnectors > 0 {
		connectorids = make([]uint32, mres.CountConnectors)
		mres.connectorIdPtr = uint64(uintptr(unsafe.Pointer(&connectorids[0])))
	}

	if err := ioctl.Call(uintptr(c.fd), uintptr(IoctlResources), uintptr(unsafe.Pointer(mres))); err != nil {
		return nil, err
	}

	return &Resources{
		sysResources: *mres,
		Fbs:          fbids,
		Crtcs:        crtcids,
		Encoders:     encoderids,
		Connectors:   connectorids,
	}, nil
}

func (c *Card) GetConnector(connid uint32) (*Connector, error) {
	conn := &sysGetConnector{ID: connid}
	if err := ioctl.Call(uintptr(c.fd), uintptr(IoctlGetConnector), uintptr(unsafe.Pointer(conn))); err != nil {
		return nil, err
	}

	var (
		props, encoders []uint32
		propValues      []uint64
		modes           []ModeInfo
	)

	if conn.countProps > 0 {
		props = make([]uint32, conn.countProps)
		conn.propsPtr = uint64(uintptr(unsafe.Pointer(&props[0])))

		propValues = make([]uint64, conn.countProps)
		conn.propValuesPtr = uint64(uintptr(unsafe.Pointer(&propValues[0])))
	}
	if conn.countModes > 0 {
		modes = make([]ModeInfo, conn.countModes)
		conn.modesPtr = uint64(uintptr(unsafe.Pointer(&modes[0])))
	}
	if conn.countEncoders > 0 {
		encoders = make([]uint32, conn.countEncoders)
		conn.encodersPtr = uint64(uintptr(unsafe.Pointer(&encoders[0])))
	}

	if err := ioctl.Call(uintptr(c.fd), uintptr(IoctlGetConnector), uintptr(unsafe.Pointer(conn))); err != nil {
		return nil, err
	}

	return &Connector{
		sysGetConnector: *conn,
		ID:              conn.ID,
		EncoderID:       conn.encoderID,
		Connection:      uint8(conn.connection),
		Width:           conn.mmWidth,
		Height:          conn.mmHeight,
		Subpixel:        uint8(conn.subpixel + 1),
		Type:            conn.connectorType,
		TypeID:          conn.connectorTypeID,
		Modes:           append([]ModeInfo(nil), modes...),
		Props:           append([]uint32(nil), props...),
		PropValues:      append([]uint64(nil), propValues...),
		Encoders:        append([]uint32(nil), encoders...),
	}, nil
}

func (c *Card) SetCrtc(crtcid, bufferid, x, y uint32, connectors *uint32, count int, mode *ModeInfo) error {
	crtc := &sysCrtc{
		id:              crtcid,
		fbID:            bufferid,
		x:               x,
		y:               y,
		countConnectors: uint32(count),
	}
	if connectors != nil {
		crtc.setConnectorsPtr = uint64(uintptr(unsafe.Pointer(connectors)))
	}
	if mode != nil {
		crtc.modeInfo = *mode
		crtc.modeValid = 1
	}

	return ioctl.Call(uintptr(c.fd), uintptr(IoctlSetCrtc), uintptr(unsafe.Pointer(crtc)))
}

func (c *Card) GetEncoder(id uint32) (*Encoder, error) {
	encoder := &sysGetEncoder{}
	encoder.id = id

	err := ioctl.Call(uintptr(c.fd), uintptr(IoctlGetEncoder),
		uintptr(unsafe.Pointer(encoder)))
	if err != nil {
		return nil, err
	}

	return &Encoder{
		ID:             encoder.id,
		CrtcID:         encoder.crtcID,
		Type:           encoder.typ,
		PossibleCrtcs:  encoder.possibleCrtcs,
		PossibleClones: encoder.possibleClones,
	}, nil
}

func (c *Card) CreateDumb(width, height uint16, bpp uint32) (*Framebuffer, error) {
	fb := &sysCreateDumb{}
	fb.width = uint32(width)
	fb.height = uint32(height)
	fb.bpp = bpp

	log.Println("createDumb", fb)
	err := ioctl.Call(uintptr(c.fd), uintptr(IoctlCreateDumb), uintptr(unsafe.Pointer(fb)))
	if err != nil {
		return nil, err
	}
	return &Framebuffer{
		Height: fb.height,
		Width:  fb.width,
		BPP:    fb.bpp,
		Handle: fb.handle,
		Pitch:  fb.pitch,
		Size:   fb.size,
	}, nil
}

func (c *Card) AddFramebuffer(width, height uint16, depth, bpp uint8, pitch, boHandle uint32) (uint32, error) {
	f := &sysFBCmd{}
	f.width = uint32(width)
	f.height = uint32(height)
	f.pitch = pitch
	f.bpp = uint32(bpp)
	f.depth = uint32(depth)
	f.handle = boHandle
	err := ioctl.Call(uintptr(c.fd), uintptr(IoctlAddFramebuffer),
		uintptr(unsafe.Pointer(f)))
	if err != nil {
		return 0, err
	}
	return f.fbID, nil
}

func (c *Card) RemoveFramebuffer(bufferid uint32) error {
	return ioctl.Call(uintptr(c.fd), uintptr(IoctlRemoveFramebuffer),
		uintptr(unsafe.Pointer(&sysRmFB{bufferid})))
}

func (c *Card) MapDumb(boHandle uint32) (uint64, error) {
	mreq := &sysMapDumb{}
	mreq.handle = boHandle
	err := ioctl.Call(uintptr(c.fd), uintptr(IoctlMapDumb), uintptr(unsafe.Pointer(mreq)))
	if err != nil {
		return 0, err
	}
	return mreq.offset, nil
}

func (c *Card) DestroyDumb(handle uint32) error {
	return ioctl.Call(uintptr(c.fd), uintptr(IoctlDestroyDumb),
		uintptr(unsafe.Pointer(&sysDestroyDumb{handle})))
}

func (c *Card) GetCrtc(id uint32) (*Crtc, error) {
	crtc := &sysCrtc{}
	crtc.id = id
	err := ioctl.Call(uintptr(c.fd), uintptr(IoctlGetCrtc), uintptr(unsafe.Pointer(crtc)))
	if err != nil {
		return nil, err
	}
	ret := &Crtc{
		ID:        crtc.id,
		X:         crtc.x,
		Y:         crtc.y,
		ModeValid: int(crtc.modeValid),
		BufferID:  crtc.fbID,
		GammaSize: int(crtc.gammaSize),
	}

	ret.ModeInfo = crtc.modeInfo
	ret.Width = uint32(crtc.modeInfo.Hdisplay)
	ret.Height = uint32(crtc.modeInfo.Vdisplay)
	return ret, nil
}
