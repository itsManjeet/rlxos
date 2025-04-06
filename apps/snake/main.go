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

package main

import (
	"image"
	"log"
	"math/rand/v2"
	"time"

	"rlxos.dev/pkg/graphics/app"
	"rlxos.dev/pkg/graphics/canvas"
	"rlxos.dev/pkg/graphics/event"
)

type Game struct {
	Snake         []image.Point
	Dir           image.Point
	Food          image.Point
	Width, Height int
	isGameOver    bool
}

func (g *Game) Init(width, height int) error {
	g.Snake = []image.Point{
		{width / 2, height / 2},
	}
	g.Width, g.Height = width, height
	g.Dir = image.Pt(1, 0)
	g.spawnFood()
	g.isGameOver = false
	return nil
}

func (g *Game) spawnFood() {
	g.Food = image.Pt(
		rand.IntN(g.Width-2)+1,
		rand.IntN(g.Height-2)+1,
	)
}

func (g *Game) Tick() time.Duration {
	return time.Second * 1
}

func (g *Game) Draw(c canvas.Canvas) {
	c.Clear()

	width, height := c.Size()
	c.DrawRectangle(0, 0, width, height)

	if g.isGameOver {
		c.DrawText("Game Over! Press Q to quit", width/2, height/2, true)
		return
	}

	c.Set(g.Food.X, g.Food.Y, '*')

	for _, p := range g.Snake {
		c.Set(p.X, p.Y, 'o')
	}

}

func (g *Game) Update(e event.Event) {
	switch e := e.(type) {
	case event.Keyboard:
		switch e.Key {
		case event.KeyUp:
			if g.Dir.Y != 1 {
				g.Dir = image.Pt(0, -1)
			}
		case event.KeyDown:
			if g.Dir.Y != -1 {
				g.Dir = image.Pt(0, 1)
			}
		case event.KeyLeft:
			if g.Dir.Y != 1 {
				g.Dir = image.Pt(-1, 0)
			}
		case event.KeyRight:
			if g.Dir.Y != -1 {
				g.Dir = image.Pt(1, 0)
			}
		}
	}

	head := g.Snake[0]
	newHead := image.Pt(head.X+g.Dir.X, head.Y+g.Dir.Y)

	if newHead.X <= 0 || newHead.Y <= 0 || newHead.X >= g.Width-1 || newHead.Y >= g.Height-1 {
		g.isGameOver = true
		return
	}

	for _, p := range g.Snake {
		if p == newHead {
			g.isGameOver = true
			return
		}
	}

	g.Snake = append([]image.Point{newHead}, g.Snake...)

	if newHead == g.Food {
		g.spawnFood()
	} else {
		g.Snake = g.Snake[:len(g.Snake)-1]
	}
}

func main() {
	game := &Game{}
	if err := app.Run(game); err != nil {
		log.Fatal(err)
	}
}
