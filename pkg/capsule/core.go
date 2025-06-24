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
	"os"
	"os/exec"
	"reflect"
	"strings"
	"syscall"
)

type checker func(args []Capsule) error

var (
	integerKind = reflect.TypeOf(int(0))
	stringKind  = reflect.TypeOf("")
	symbolKind  = reflect.TypeOf(Symbol(""))
	palleteKind = reflect.TypeOf(Pallete{})
	mapKind     = reflect.TypeOf(Map{})
	processKind = reflect.TypeOf(builtinEval)
	lambdaKind  = reflect.TypeOf(Lambda{})
	anyKind     = reflect.TypeOf(nil)
)

func builtinAdd(pallete Pallete) (Capsule, error) {
	if err := checkPallete("+", pallete, []checker{
		allOfKind(integerKind),
	}); err == nil {
		var result int
		for _, p := range pallete {
			result += p.(int)
		}
		return result, nil
	} else if err := checkPallete("+", pallete, []checker{
		allOfKind(stringKind),
	}); err == nil {
		var result string
		for _, p := range pallete {
			result += p.(string)
		}
		return result, nil
	} else if err := checkPallete("+", pallete, []checker{
		allOfKind(palleteKind),
	}); err == nil {
		var result Pallete
		for _, p := range pallete {
			result = append(result, p.(Pallete)...)
		}
		return result, nil
	}
	return nil, fmt.Errorf("+ invalid type")
}

func builtinSub(pallete Pallete) (Capsule, error) {
	if err := checkPallete("-", pallete, []checker{
		allOfKind(integerKind),
	}); err != nil {
		return nil, err
	}

	var result int
	for _, p := range pallete {
		result -= p.(int)
	}
	return result, nil
}

func builtinMul(pallete Pallete) (Capsule, error) {
	if err := checkPallete("*", pallete, []checker{
		allOfKind(integerKind),
	}); err != nil {
		return nil, err
	}

	var result int
	for _, p := range pallete {
		result *= p.(int)
	}
	return result, nil
}

func builtinDiv(pallete Pallete) (Capsule, error) {
	if err := checkPallete("/", pallete, []checker{
		allOfKind(integerKind),
	}); err != nil {
		return nil, err
	}

	var result int
	for _, p := range pallete {
		result /= p.(int)
	}
	return result, nil
}

func builtinCons(pallete Pallete) (Capsule, error) {
	if err := checkPallete("CONS", pallete, []checker{
		hasExactCount(2),
		ofKinds(anyKind, palleteKind),
	}); err != nil {
		return nil, err
	}

	first := pallete[0]
	remaining := pallete[1].(Pallete)

	return append(Pallete{first}, remaining...), nil
}

func builtinConcat(pallete Pallete) (Capsule, error) {
	if err := checkPallete("CONCAT", pallete, []checker{
		hasAtleast(1),
		allOfKind(palleteKind),
	}); err != nil {
		return nil, err
	}
	if len(pallete) == 0 {
		return Pallete{}, nil
	}

	p := pallete[0].(Pallete)

	for i := 1; i < len(pallete); i++ {
		v := pallete[i].(Pallete)
		p = append(p, v...)
	}

	return p, nil
}

func builtinEval(pallete Pallete) (Capsule, error) {
	if err := checkPallete("EVAL", pallete, []checker{
		hasExactCount(1),
		ofKinds(stringKind),
	}); err != nil {
		return nil, err
	}

	return Eval(pallete[0].(string))
}

func builtinExec(pallete Pallete) (Capsule, error) {
	if err := checkPallete("EXEC", pallete, []checker{
		hasAtleast(1),
		ofKinds(stringKind),
	}); err != nil {
		return nil, err
	}

	args := make([]string, 0, len(pallete))
	for _, p := range pallete {
		args = append(args, p.(string))
	}

	cmd := exec.Command(args[0], args[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		return nil, err
	}
	return cmd.ProcessState.ExitCode(), nil
}

func builtinEnviron(pallete Pallete) (Capsule, error) {
	if err := checkPallete("ENVIRON", pallete, []checker{
		hasAtleast(1),
		ofKinds(stringKind),
	}); err != nil {
		return nil, err
	}

	switch len(pallete) {
	case 1:
		return os.Getenv(pallete[0].(string)), nil
	default:
		err := os.Setenv(pallete[0].(string), pallete[1].(string))
		return nil, err
	}
}

func builtinWrite(pallete Pallete) (Capsule, error) {
	if err := checkPallete("WRITE", pallete, []checker{
		hasExactCount(2),
		ofKinds(integerKind, stringKind),
	}); err != nil {
		return nil, err
	}

	return syscall.Write(pallete[0].(int), []byte(pallete[1].(string)))
}

func builtinRead(pallete Pallete) (Capsule, error) {
	if err := checkPallete("READ", pallete, []checker{
		hasExactCount(2),
		ofKinds(integerKind, integerKind),
	}); err != nil {
		return nil, err
	}

	buffer := make([]byte, pallete[1].(int))
	n, err := syscall.Read(pallete[0].(int), buffer)
	if err != nil {
		return nil, fmt.Errorf("(READ :FD :SIZE) %v", err)
	}
	return string(buffer[:n]), nil
}

func builtinOpen(pallete Pallete) (Capsule, error) {
	if err := checkPallete("OPEN", pallete, []checker{
		hasExactCount(3),
		ofKinds(stringKind, integerKind, integerKind),
	}); err != nil {
		return nil, err
	}

	fd, err := syscall.Open(pallete[0].(string), pallete[1].(int), uint32(pallete[2].(int)))
	return fd, err
}

func builtinClose(pallete Pallete) (Capsule, error) {
	if err := checkPallete("CLOSE", pallete, []checker{
		hasExactCount(1),
		ofKinds(integerKind),
	}); err != nil {
		return nil, err
	}
	return nil, syscall.Close(pallete[0].(int))
}

func builtinExit(pallete Pallete) (Capsule, error) {
	if err := checkPallete("EXIT", pallete, []checker{
		hasExactCount(1),
		ofKinds(integerKind),
	}); err != nil {
		return nil, err
	}

	os.Exit(pallete[0].(int))
	return nil, nil
}

func builtinChdir(pallete Pallete) (Capsule, error) {
	if err := checkPallete("CHDIR", pallete, []checker{
		hasExactCount(1),
		ofKinds(stringKind),
	}); err != nil {
		return nil, err
	}

	return nil, os.Chdir(pallete[0].(string))
}

func ofKind(id string, kind reflect.Type) Process {
	return func(pallete Pallete) (Capsule, error) {
		if err := checkPallete(strings.ToUpper(id)+"?", pallete, []checker{
			hasExactCount(1),
		}); err != nil {
			return nil, err
		}
		return kind == reflect.TypeOf(pallete[0]), nil
	}
}

func registerBuiltins(scope *Scope) {
	for key, value := range map[string]Capsule{
		"+":       builtinAdd,
		"-":       builtinSub,
		"*":       builtinMul,
		"/":       builtinDiv,
		"cons":    builtinCons,
		"concat":  builtinConcat,
		"int?":    ofKind("int", integerKind),
		"str?":    ofKind("str", stringKind),
		"nil?":    ofKind("nil", anyKind),
		"list?":   ofKind("list", palleteKind),
		"map?":    ofKind("map", mapKind),
		"proc?":   ofKind("proc", processKind),
		"lambda?": ofKind("lambda", lambdaKind),
		"eval":    builtinEval,
		"open":    builtinOpen,
		"close":   builtinClose,
		"read":    builtinRead,
		"write":   builtinWrite,
		"exit":    builtinExit,
		"chdir":   builtinChdir,
		"#T":      true,
		"#F":      false,
		"#N":      nil,
		"exec":    builtinExec,
		"environ": builtinEnviron,
	} {
		scope.Set(Symbol(strings.ToUpper(key)), value)
	}
}

func checkPallete(id string, args []Capsule, funs []checker) error {
	for _, f := range funs {
		if err := f(args); err != nil {
			return fmt.Errorf("(%s) %v", id, err)
		}
	}
	return nil
}

func hasExactCount(count int) checker {
	return func(pallete Pallete) error {
		if len(pallete) != count {
			return fmt.Errorf("expect %d argument(s) but %d given", count, len(pallete))
		}
		return nil
	}
}

func hasAtleast(count int) checker {
	return func(pallete Pallete) error {
		if len(pallete) < count {
			return fmt.Errorf("expect atleast %d argument(s) but %d given", count, len(pallete))
		}
		return nil
	}
}

func ofKinds(kinds ...reflect.Type) checker {
	return func(pallete Pallete) error {
		for i, t := range kinds {
			if i < len(pallete) && reflect.TypeOf(pallete[i]) != t && t != nil {
				return fmt.Errorf("expect #%d to be %v but got %v", i,
					t.Name(), reflect.TypeOf(pallete[i]).Name())
			}
		}
		return nil
	}
}

func allOfKind(kind reflect.Type) checker {
	return func(pallete Pallete) error {
		for _, p := range pallete {
			if reflect.TypeOf(p) != kind && kind != nil {
				return fmt.Errorf("expect #%d to be %v but got %v", kind,
					kind.Name(), reflect.TypeOf(p).Name())
			}
		}
		return nil
	}
}

func eitherOf(checkers ...checker) checker {
	var err error
	return func(pallete Pallete) error {
		for _, c := range checkers {
			if err = c(pallete); err == nil {
				return nil
			}
		}
		return err
	}
}
