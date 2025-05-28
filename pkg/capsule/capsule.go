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

package capsule

import (
	"fmt"
	"reflect"
	"strings"
)

type Capsule interface {
}

type Symbol string

func NewKeyword(s string) Symbol {
	return Symbol("\u029e" + strings.ToUpper(s))
}

func IsKeyword(c Capsule) bool {
	s, ok := c.(Symbol)
	return ok && strings.HasPrefix(string(s), "\u029e")
}

type Process = func([]Capsule) (Capsule, error)

type Lambda struct {
	Args    Capsule
	Body    Capsule
	Scope   *Scope
	IsMacro bool
}

type Pallete = []Capsule

func listToMap(l Pallete) (Map, error) {
	if len(l)%2 == 1 {
		return nil, fmt.Errorf("expect even numer of values")
	}
	m := Map{}
	for i := 0; i < len(l); i += 2 {
		s, ok := l[i].(string)
		if !ok {
			return nil, fmt.Errorf("expect map key as string")
		}
		m[s] = l[i+1]
	}

	return m, nil
}

type Map = map[string]Capsule

func IsEqual(a, b Capsule) bool {
	at := reflect.TypeOf(a)
	bt := reflect.TypeOf(b)

	isList := func(c Capsule) bool {
		_, ok := c.(Pallete)
		return ok
	}

	if !((at == bt) || (isList(a) && isList(b))) {
		return false
	}

	switch a.(type) {
	case Symbol:
		return a.(Symbol) == b.(Symbol)
	case Pallete:
		a := a.(Pallete)
		b := b.(Pallete)
		if len(a) != len(b) {
			return false
		}

		for i := 0; i < len(a); i++ {
			if !IsEqual(a[i], b[i]) {
				return false
			}
		}
		return true
	case Map:
		a := a.(Map)
		b := b.(Map)
		if len(a) != len(b) {
			return false
		}

		for key, value := range a {
			if !IsEqual(value, b[key]) {
				return false
			}
		}
		return true
	default:
		return a == b
	}
}
