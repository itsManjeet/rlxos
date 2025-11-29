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
	"io/fs"
	"os"
	"os/exec"
	"reflect"
	"strings"
	"syscall"
)

type checker func(args []Value) error

var (
	NumberKind  = reflect.TypeOf(int(0))
	StringKind  = reflect.TypeOf("")
	BoolKind    = reflect.TypeOf(true)
	SymbolKind  = reflect.TypeOf(Symbol(""))
	ListKind    = reflect.TypeOf([]Value{})
	MapKind     = reflect.TypeOf(Map{})
	ProcessKind = reflect.TypeOf(builtinEval)
	FunKind     = reflect.TypeOf(Function{})
	AnyKind     = reflect.TypeOf(nil)
)

func builtinAdd(args []Value) (Value, error) {
	if err := CheckArgs("+", args, []checker{
		AllOfKind(NumberKind),
	}); err == nil {
		var result int
		for _, p := range args {
			result += p.(int)
		}
		return result, nil
	} else if err := CheckArgs("+", args, []checker{
		AllOfKind(StringKind),
	}); err == nil {
		var result string
		for _, p := range args {
			result += p.(string)
		}
		return result, nil
	} else if err := CheckArgs("+", args, []checker{
		AllOfKind(ListKind),
	}); err == nil {
		var result []Value
		for _, p := range args {
			result = append(result, p.([]Value)...)
		}
		return result, nil
	}
	return nil, fmt.Errorf("+ invalid type")
}

func builtinSub(args []Value) (Value, error) {
	if err := CheckArgs("-", args, []checker{
		AllOfKind(NumberKind),
	}); err != nil {
		return nil, err
	}

	var result int
	for _, p := range args {
		result -= p.(int)
	}
	return result, nil
}

func builtinMul(args []Value) (Value, error) {
	if err := CheckArgs("*", args, []checker{
		AllOfKind(NumberKind),
	}); err != nil {
		return nil, err
	}

	var result int
	for _, p := range args {
		result *= p.(int)
	}
	return result, nil
}

func builtinDiv(args []Value) (Value, error) {
	if err := CheckArgs("/", args, []checker{
		AllOfKind(NumberKind),
	}); err != nil {
		return nil, err
	}

	var result int
	for _, p := range args {
		result /= p.(int)
	}
	return result, nil
}

func builtinCons(args []Value) (Value, error) {
	if err := CheckArgs("cons", args, []checker{
		HasExactCount(2),
		OfKinds(AnyKind, ListKind),
	}); err != nil {
		return nil, err
	}

	first := args[0]
	remaining := args[1].([]Value)

	return append([]Value{first}, remaining...), nil
}

func builtinConcat(args []Value) (Value, error) {
	if err := CheckArgs("concat", args, []checker{
		HasAtleast(1),
		AllOfKind(ListKind),
	}); err != nil {
		return nil, err
	}
	if len(args) == 0 {
		return []Value{}, nil
	}

	p := args[0].([]Value)

	for i := 1; i < len(args); i++ {
		v := args[i].([]Value)
		p = append(p, v...)
	}

	return p, nil
}

func builtinEval(args []Value) (Value, error) {
	if err := CheckArgs("eval", args, []checker{
		HasExactCount(1),
		OfKinds(StringKind),
	}); err != nil {
		return nil, err
	}

	return Eval(args[0].(string))
}

func builtinExec(args []Value) (Value, error) {
	if err := CheckArgs("exec", args, []checker{
		HasAtleast(1),
		OfKinds(StringKind),
	}); err != nil {
		return nil, err
	}

	cmd_args := make([]string, 0, len(args))
	for _, p := range args {
		cmd_args = append(cmd_args, p.(string))
	}

	cmd := exec.Command(cmd_args[0], cmd_args[1:]...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	if err := cmd.Run(); err != nil {
		return nil, err
	}
	return cmd.ProcessState.ExitCode(), nil
}

func builtinEnv(args []Value) (Value, error) {
	if err := CheckArgs("env", args, []checker{
		HasAtleast(1),
		OfKinds(StringKind),
	}); err != nil {
		return nil, err
	}

	switch len(args) {
	case 1:
		return os.Getenv(args[0].(string)), nil
	default:
		err := os.Setenv(args[0].(string), args[1].(string))
		return nil, err
	}
}

func builtinWrite(args []Value) (Value, error) {
	if err := CheckArgs("write", args, []checker{
		HasAtleast(1),
		EitherOf(OfKinds(StringKind), OfKinds(NumberKind)),
	}); err != nil {
		return nil, err
	}

	var content string
	if len(args) >= 2 {
		content = ToString(args[1])
	}

	perm := 0644
	if len(args) == 3 {
		if p, ok := args[2].(int); !ok {
			return nil, fmt.Errorf("(write) invalid file permission %v", ToString(args[2]))
		} else {
			perm = p
		}

	}

	if filename, ok := args[0].(string); ok {
		if err := os.WriteFile(filename, []byte(content), fs.FileMode(perm)); err != nil {
			return nil, err
		}
	} else if fd, ok := args[0].(int); ok {
		return syscall.Write(fd, []byte(content))
	}

	return nil, fmt.Errorf("(write) invalid filename %v", ToString(args[0]))
}

func builtinRead(args []Value) (Value, error) {
	if err := CheckArgs("read", args, []checker{
		HasAtleast(1),
		EitherOf(OfKinds(StringKind), OfKinds(NumberKind)),
	}); err != nil {
		return nil, err
	}

	if filename, ok := args[0].(string); ok {
		data, err := os.ReadFile(filename)
		if err != nil {
			return nil, err
		}
		return string(data), nil
	} else if fd, ok := args[0].(int); ok {
		bufferSize := 8196
		if len(args) == 2 {
			if size, ok := args[1].(int); ok {
				bufferSize = size
			} else {
				return nil, fmt.Errorf("(read) invalid buffer size:int = %v", ToString(args[1]))
			}
		}
		buf := make([]byte, bufferSize)
		n, err := syscall.Read(fd, buf)
		if err != nil {
			return nil, err
		}

		return string(buf[:n]), nil
	}

	return nil, fmt.Errorf("(read) invalid filename:string = %v", ToString(args[0]))
}

func builtinExit(args []Value) (Value, error) {
	if err := CheckArgs("exit", args, []checker{
		HasExactCount(1),
		OfKinds(NumberKind),
	}); err != nil {
		return nil, err
	}

	os.Exit(args[0].(int))
	return nil, nil
}

func builtinChdir(args []Value) (Value, error) {
	if err := CheckArgs("chdir", args, []checker{
		HasExactCount(1),
		OfKinds(StringKind),
	}); err != nil {
		return nil, err
	}

	return nil, os.Chdir(args[0].(string))
}

func builtinListDir(args []Value) (Value, error) {
	var dir string
	if len(args) >= 1 {
		dir = args[0].(string)
	} else {
		dir, _ = os.Getwd()
	}

	content, err := os.ReadDir(dir)
	if err != nil {
		return nil, err
	}

	var files []Value
	for _, c := range content {
		info, _ := c.Info()
		sysinfo := info.Sys().(*syscall.Stat_t)
		files = append(files, Map{
			"name":   c.Name(),
			"size":   int(sysinfo.Size),
			"is-dir": c.IsDir(),
		})
	}

	return files, nil
}

func OfKind(id string, kind reflect.Type) Process {
	return func(args []Value) (Value, error) {
		if err := CheckArgs(strings.ToUpper(id)+"?", args, []checker{
			HasExactCount(1),
		}); err != nil {
			return nil, err
		}
		return kind == reflect.TypeOf(args[0]), nil
	}
}

func RegisterInScope(scope *Scope, key string, value Value) {
	scope.Set(Symbol(key), value)
}

func Register(key string, value Value) {
	RegisterInScope(Global, key, value)
}

func registerBuiltins(scope *Scope) {
	for key, value := range map[string]Value{
		"+":        builtinAdd,
		"-":        builtinSub,
		"*":        builtinMul,
		"/":        builtinDiv,
		"cons":     builtinCons,
		"concat":   builtinConcat,
		"int?":     OfKind("int", NumberKind),
		"str?":     OfKind("str", StringKind),
		"nil?":     OfKind("nil", AnyKind),
		"list?":    OfKind("list", ListKind),
		"map?":     OfKind("map", MapKind),
		"proc?":    OfKind("proc", ProcessKind),
		"lambda?":  OfKind("lambda", FunKind),
		"eval":     builtinEval,
		"read":     builtinRead,
		"write":    builtinWrite,
		"exit":     builtinExit,
		"chdir":    builtinChdir,
		"#T":       true,
		"#F":       false,
		"#N":       nil,
		"exec":     builtinExec,
		"env":      builtinEnv,
		"list-dir": builtinListDir,
	} {
		RegisterInScope(scope, key, value)
	}
}

func CheckArgs(id string, args []Value, funs []checker) error {
	for _, f := range funs {
		if err := f(args); err != nil {
			return fmt.Errorf("(%s) %v", id, err)
		}
	}
	return nil
}

func HasExactCount(count int) checker {
	return func(args []Value) error {
		if len(args) != count {
			return fmt.Errorf("expect %d argument(s) but %d given", count, len(args))
		}
		return nil
	}
}

func HasAtleast(count int) checker {
	return func(args []Value) error {
		if len(args) < count {
			return fmt.Errorf("expect atleast %d argument(s) but %d given", count, len(args))
		}
		return nil
	}
}

func OfKinds(kinds ...reflect.Type) checker {
	return func(args []Value) error {
		for i, t := range kinds {
			if i < len(args) && reflect.TypeOf(args[i]) != t && t != nil {
				return fmt.Errorf("expect #%d to be %v but got %v", i,
					t.Name(), reflect.TypeOf(args[i]).Name())
			}
		}
		return nil
	}
}

func AllOfKind(kind reflect.Type) checker {
	return func(args []Value) error {
		for _, p := range args {
			if reflect.TypeOf(p) != kind && kind != nil {
				return fmt.Errorf("expect #%d to be %v but got %v", kind,
					kind.Name(), reflect.TypeOf(p).Name())
			}
		}
		return nil
	}
}

func EitherOf(checkers ...checker) checker {
	var err error
	return func(args []Value) error {
		for _, c := range checkers {
			if err = c(args); err == nil {
				return nil
			}
		}
		return err
	}
}
