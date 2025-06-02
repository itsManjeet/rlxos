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

package graphics

import (
	"image/color"

	"rlxos.dev/pkg/graphics/argb"
)

var (
	OutlineRadius    = 5
	OutlineThickness = 2
	// Basic Colors
	ColorWhite = argb.NewColor(255, 255, 255, 255)
	ColorBlack = argb.NewColor(0, 0, 0, 255)
	ColorRed   = argb.NewColor(255, 0, 0, 255)
	ColorGreen = argb.NewColor(0, 255, 0, 255)
	ColorBlue  = argb.NewColor(0, 0, 255, 255)

	// Extended Palette
	ColorCyan      = argb.NewColor(0, 255, 255, 255)
	ColorMagenta   = argb.NewColor(255, 0, 255, 255)
	ColorYellow    = argb.NewColor(255, 255, 0, 255)
	ColorGray      = argb.NewColor(128, 128, 128, 255)
	ColorLightGray = argb.NewColor(200, 200, 200, 255)
	ColorDarkGray  = argb.NewColor(64, 64, 64, 255)
	ColorOrange    = argb.NewColor(255, 165, 0, 255)
	ColorPurple    = argb.NewColor(128, 0, 128, 255)
	ColorBrown     = argb.NewColor(139, 69, 19, 255)
	ColorPink      = argb.NewColor(255, 192, 203, 255)
	ColorTeal      = argb.NewColor(0, 128, 128, 255)
	ColorOlive     = argb.NewColor(128, 128, 0, 255)

	// Transparent
	ColorTransparent = argb.NewColor(0, 0, 0, 0)

	// Primary brand colors
	Primary   = argb.NewColor(98, 0, 238, 255)    // Deep Purple
	OnPrimary = argb.NewColor(255, 255, 255, 255) // White

	PrimaryVariant   = argb.NewColor(55, 0, 179, 255) // Darker Purple
	OnPrimaryVariant = OnPrimary

	// Secondary colors
	Secondary   = argb.NewColor(3, 218, 197, 255) // Teal
	OnSecondary = argb.NewColor(0, 0, 0, 255)     // Black

	SecondaryVariant   = argb.NewColor(1, 135, 134, 255)
	OnSecondaryVariant = OnSecondary

	// Background colors
	Background   = argb.NewColor(245, 245, 245, 255) // Light Grey
	OnBackground = argb.NewColor(0, 0, 0, 255)       // Black

	// Surface colors (e.g., cards, sheets)
	Surface   = argb.NewColor(255, 255, 255, 255) // White
	OnSurface = argb.NewColor(0, 0, 0, 255)       // Black

	// Error colors
	Error   = argb.NewColor(176, 0, 32, 255)    // Red-ish
	OnError = argb.NewColor(255, 255, 255, 255) // White

	// Outline / Divider
	Outline = argb.NewColor(189, 189, 189, 255) // Mid Grey

	// Inverse colors (for dark mode or elevation)
	InverseSurface   = argb.NewColor(48, 48, 48, 255)
	OnInverseSurface = argb.NewColor(255, 255, 255, 255)

	// Shadow or overlay
	Shadow = argb.NewColor(0, 0, 0, 128) // Semi-transparent black
)

type _N interface {
	float64 | int | uint32
}

func clamp[T _N](x T) uint8 {
	if x < 0 {
		return 0
	}
	if x > 255 {
		return 255
	}
	return uint8(x)
}

func Lighten(c color.Color, amount float64) color.Color {
	r, g, b, a := c.RGBA()
	rf := float64(r) + (255-float64(r))*amount
	gf := float64(g) + (255-float64(g))*amount
	bf := float64(b) + (255-float64(b))*amount
	return argb.NewColor(clamp(rf), clamp(gf), clamp(bf), clamp(a))
}

func Darken(c color.Color, amount float64) color.Color {
	r, g, b, a := c.RGBA()
	rf := float64(r) * (1 - amount)
	gf := float64(g) * (1 - amount)
	bf := float64(b) * (1 - amount)
	return argb.NewColor(clamp(rf), clamp(gf), clamp(bf), clamp(a))
}
