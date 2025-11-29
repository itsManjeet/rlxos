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

package lipi

import (
	"fmt"
)

type Scope struct {
	store  map[Symbol]Value
	parent *Scope
}

var (
	Global *Scope
)

func init() {
	Global = &Scope{
		store:  map[Symbol]Value{},
		parent: nil,
	}

	registerBuiltins(Global)
	EvalInScope("(define (not v) (if v #f #t))", Global)
}

func createNestedScope(parent *Scope, bindings Value, exprs Value) (*Scope, error) {
	s := Scope{
		store:  map[Symbol]Value{},
		parent: parent,
	}

	if bindings != nil && exprs != nil {
		bindings, ok := bindings.(List)
		if !ok {
			return nil, fmt.Errorf("expected bindings to be List")
		}
		exprs, ok := exprs.(List)
		if !ok {
			return nil, fmt.Errorf("expect exprs to be List")
		}

		if len(bindings) != len(exprs) {
			return nil, fmt.Errorf("expect (len exprs) == (len bindings)")
		}
		for i := 0; i < len(bindings); i++ {
			if _, ok := bindings[i].(Symbol); ok && bindings[i].(Symbol) == "&" {
				s.store[bindings[i+1].(Symbol)] = exprs[i:]
				break
			} else {
				s.store[bindings[i].(Symbol)] = exprs[i]
			}
		}
	}

	return &s, nil
}

func (s *Scope) Lookup(id Symbol) *Scope {
	if _, ok := s.store[id]; ok {
		return s
	} else if s.parent != nil {
		return s.parent.Lookup(id)
	}
	return nil
}

func (s *Scope) Set(id Symbol, c Value) Value {
	s.store[id] = c
	return c
}

func (s *Scope) Get(id Symbol) (Value, error) {
	scope := s.Lookup(id)
	if scope == nil {
		return nil, fmt.Errorf("unbounded value %v", id)
	}
	return scope.store[id], nil
}
