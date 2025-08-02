package style

import (
	"image/color"

	"rlxos.dev/pkg/graphics/argb"
)

type Style struct {
	Background   color.Color
	OnBackground color.Color

	Surface   color.Color
	OnSurface color.Color

	Primary   color.Color
	OnPrimary color.Color

	Secondary   color.Color
	OnSecondary color.Color

	Outline       int
	OutlineRadius int

	Title      int
	Heading    int
	SubHeading int
	Paragraph  int
}

var (
	Default Style = Light

	Light = Style{
		Background:   color.RGBA{R: 250, G: 250, B: 250, A: 255},
		OnBackground: color.RGBA{R: 28, G: 27, B: 31, A: 255},

		Surface:   color.RGBA{R: 255, G: 255, B: 255, A: 255},
		OnSurface: color.RGBA{R: 28, G: 27, B: 31, A: 255},

		Primary:   color.RGBA{R: 103, G: 80, B: 164, A: 255},
		OnPrimary: color.RGBA{R: 255, G: 255, B: 255, A: 255},

		Secondary:   color.RGBA{R: 98, G: 91, B: 113, A: 255},
		OnSecondary: color.RGBA{R: 255, G: 255, B: 255, A: 255},

		Outline:       1,
		OutlineRadius: 8,

		Title:      16,
		Heading:    12,
		SubHeading: 10,
		Paragraph:  8,
	}

	Dark = Style{
		Background:   color.RGBA{R: 20, G: 19, B: 24, A: 255},
		OnBackground: color.RGBA{R: 230, G: 225, B: 229, A: 255},

		Surface:   color.RGBA{R: 28, G: 27, B: 31, A: 255},
		OnSurface: color.RGBA{R: 230, G: 225, B: 229, A: 255},

		Primary:   color.RGBA{R: 208, G: 188, B: 255, A: 255},
		OnPrimary: color.RGBA{R: 55, G: 30, B: 115, A: 255},

		Secondary:   color.RGBA{R: 204, G: 194, B: 220, A: 255},
		OnSecondary: color.RGBA{R: 50, G: 45, B: 65, A: 255},

		Outline:       1,
		OutlineRadius: 8,

		Title:      16,
		Heading:    12,
		SubHeading: 10,
		Paragraph:  8,
	}
)

// Numeric constraint
type _N interface {
	~float64 | ~int | ~uint32
}

// Clamp value to [0, 255]
func clamp[T _N](x T) uint8 {
	if x < 0 {
		return 0
	}
	if x > 255 {
		return 255
	}
	return uint8(x)
}

// Convert 16-bit channel to 8-bit
func to8bit(v uint32) uint8 {
	return uint8(v >> 8)
}

// Lighten: blend with white based on amount (0.0 to 1.0)
func Lighten(c color.Color, amount float64) color.Color {
	r, g, b, a := c.RGBA()
	rf := float64(to8bit(r)) + (255-float64(to8bit(r)))*amount
	gf := float64(to8bit(g)) + (255-float64(to8bit(g)))*amount
	bf := float64(to8bit(b)) + (255-float64(to8bit(b)))*amount
	return argb.NewColor(clamp(rf), clamp(gf), clamp(bf), to8bit(a))
}

// Darken: scale color toward black by amount (0.0 to 1.0)
func Darken(c color.Color, amount float64) color.Color {
	r, g, b, a := c.RGBA()
	rf := float64(to8bit(r)) * (1 - amount)
	gf := float64(to8bit(g)) * (1 - amount)
	bf := float64(to8bit(b)) * (1 - amount)
	return argb.NewColor(clamp(rf), clamp(gf), clamp(bf), to8bit(a))
}

// Alpha: replace alpha value
func Alpha(c color.Color, a uint8) color.Color {
	r, g, b, _ := c.RGBA()
	return argb.NewColor(to8bit(r), to8bit(g), to8bit(b), a)
}
