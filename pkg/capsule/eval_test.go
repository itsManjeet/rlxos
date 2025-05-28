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
	"testing"

	"github.com/go-test/deep"
)

func check(t *testing.T, source string, expected Capsule) {
	capsule, err := Read(source)
	if err != nil {
		t.Fatal(err)
	}

	nestedScope, _ := createNestedScope(Global, nil, nil)
	actual, err := EvalCapsuleInScope(capsule, nestedScope)
	if err != nil {
		t.Fatal(err)
	}

	if diff := deep.Equal(expected, actual); diff != nil {
		t.Fatalf("%s %v", source, diff)
	}
}

func TestEvalQuote(t *testing.T) {
	check(t, "(quote (1 2 3))", Pallete{1, 2, 3})
	check(t, "'(+ 1 2)", Pallete{Symbol("+"), 1, 2})
}
