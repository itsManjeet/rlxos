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

package scene

import (
	"image"
	"image/draw"
)

type Node struct {
	Name    string
	Pos     image.Point
	Visible bool
	Surface image.Image

	Damaged  bool
	Children []*Node
	Parent   *Node
}

func NewNode(name string, surface image.Image, pos image.Point) *Node {
	return &Node{
		Name:    name,
		Pos:     pos,
		Visible: true,
		Surface: surface,
		Damaged: true,
	}
}

func (n *Node) AddChild(child *Node) {
	child.Parent = n
	n.Children = append(n.Children, child)
}

func (n *Node) SetDamage(d bool) {
	n.Damaged = d
	if n.Parent != nil {
		n.Parent.SetDamage(d)
	}
}

func (n *Node) AbsPos() image.Point {
	if n.Parent == nil {
		return n.Pos
	}
	return n.Pos.Add(n.Parent.AbsPos())
}

func (n *Node) CollectDamage() []image.Rectangle {
	var damage []image.Rectangle
	if n.Damaged && n.Visible && n.Surface != nil {
		pos := n.AbsPos()
		r := image.Rectangle{
			Min: pos,
			Max: pos.Add(n.Surface.Bounds().Size()),
		}
		damage = append(damage, r)
		n.Damaged = false
	}

	for _, child := range n.Children {
		damage = append(damage, child.CollectDamage()...)
	}
	return damage
}

func (n *Node) Render(dst draw.Image, damage []image.Rectangle) {
	if !n.Visible {
		return
	}

	if n.Surface != nil {
		pos := n.AbsPos()
		bounds := image.Rectangle{
			Min: pos,
			Max: pos.Add(n.Surface.Bounds().Size()),
		}

		for _, d := range damage {
			if drawRegion := bounds.Intersect(d); !drawRegion.Empty() {
				srcStart := drawRegion.Min.Sub(pos)
				draw.Draw(dst, drawRegion, n.Surface, srcStart, draw.Over)
			}
		}
	}

	for _, child := range n.Children {
		child.Render(dst, damage)
	}
}
