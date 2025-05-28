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
	"testing"

	"github.com/go-test/deep"
)

func TestReaderInteger(t *testing.T) {
	actual := 10
	expected, err := readToken(&reader{
		tokens: []string{fmt.Sprint(actual)},
		pos:    0,
	})
	if err != nil {
		t.Fatal(err)
	}

	if !reflect.DeepEqual(actual, expected) {
		t.Fatalf("'%v:%T' != '%v:%T'", actual, actual, expected, expected)
	}
}

func TestReadCall(t *testing.T) {
	actual := []Capsule{Symbol("EVAL"), 10}
	expected, err := read(&reader{
		tokens: []string{"(", "EVAL", "10", ")"},
		pos:    0,
	})
	if err != nil {
		t.Fatal(err)
	}

	if diff := deep.Equal(actual, expected); diff != nil {
		t.Fatal(diff)
	}
}
