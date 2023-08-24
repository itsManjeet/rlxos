package font

import "unsafe"

type Psf2 struct {
	Magic         uint32
	Version       uint32
	HeaderSize    uint32
	Flags         uint32
	GlyphCount    uint32
	BytesPerGlyph uint32
	Height        uint32
	Width         uint32
	Glyph         uint32
}

func Load() *Psf2 {
	font := (*Psf2)(unsafe.Pointer(&psf2BinaryBolb))
	_ = unsafe.Slice(&font.Glyph, font.BytesPerGlyph*font.GlyphCount)
	return font
}
