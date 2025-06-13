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
	"strings"
)

func startsWith(list []Capsule, s Symbol) bool {
	if len(list) > 0 {
		switch i := list[0].(type) {
		case Symbol:
			return s == i
		default:
		}
	}
	return false
}

func quasiQuoteLoop(pallete Pallete) Capsule {
	var p Pallete
	for i := len(pallete) - 1; 0 <= i; i -= 1 {
		v := pallete[i]
		switch v := v.(type) {
		case Pallete:
			if startsWith(v, "SPLICE-UNQUOTE") {
				p = Pallete{Symbol("CONCAT"), v[1], p}
				continue
			}
		default:
		}
		p = Pallete{Symbol("CONS"), quasiQuote(v), p}
	}
	return p
}

func quasiQuote(cap Capsule) Capsule {
	switch cap := cap.(type) {
	case Symbol, Map:
		return Pallete{Symbol("QUOTE"), cap}
	case Pallete:
		if startsWith(cap, Symbol("UNQUOTE")) {
			return cap[1]
		} else {
			return quasiQuoteLoop(cap)
		}
	default:
		return cap
	}
}

func evalMap(pallete Pallete, scope *Scope) (Pallete, error) {
	var result Pallete
	for _, p := range pallete {
		expr, err := EvalCapsuleInScope(p, scope)
		if err != nil {
			return nil, err
		}
		result = append(result, expr)
	}
	return result, nil
}

func EvalCapsuleInScope(capsule Capsule, scope *Scope) (Capsule, error) {
	for {
		if id, ok := capsule.(Symbol); ok {
			return scope.Get(id)
		} else if _, ok := capsule.(Map); ok {
			evaluatedMap := map[string]Capsule{}
			for key, value := range capsule.(Map) {
				evaluatedValue, err := EvalCapsuleInScope(value, scope)
				if err != nil {
					return nil, err
				}
				evaluatedMap[key] = evaluatedValue
			}
			return evaluatedMap, nil
		} else if _, ok := capsule.(Pallete); !ok {
			return capsule, nil
		} else {
			if len(capsule.(Pallete)) == 0 {
				return capsule, nil
			}

			callee := capsule.(Pallete)[0]
			args := capsule.(Pallete)[1:]

			callee_id := ""
			if _, ok := callee.(Symbol); ok {
				callee_id = strings.ToUpper(string(callee.(Symbol)))
			}

			switch callee_id {
			case "DEFINE":
				if err := checkPallete("DEFINE", args, []checker{
					hasExactCount(2),
					eitherOf(
						ofKinds(symbolKind, anyKind),
						ofKinds(palleteKind, anyKind),
					),
				}); err != nil {
					return nil, err
				}

				if id, ok := args[0].(Symbol); ok {
					value, err := EvalCapsuleInScope(args[1], scope)
					if err != nil {
						return nil, err
					}
					return scope.Set(id, value), nil
				} else if parameters, ok := args[0].(Pallete); ok {
					if err := checkPallete("DEFINE FUN", parameters, []checker{
						hasAtleast(1),
						allOfKind(symbolKind),
					}); err != nil {
						return nil, err
					}

					id := parameters[0].(Symbol)
					parameters = parameters[1:]

					return scope.Set(id, Lambda{
						Args:    parameters,
						Body:    args[1],
						Scope:   scope,
						IsMacro: false,
					}), nil
				} else {
					return nil, fmt.Errorf("DEFINE unexpected pallete")
				}

			case "LET":
				if err := checkPallete("LET", args, []checker{
					hasExactCount(2),
					ofKinds(palleteKind),
				}); err != nil {
					return nil, err
				}

				nestedScope, err := createNestedScope(scope, nil, nil)
				if err != nil {
					return nil, err
				}

				definations := args[0].(Pallete)
				for i := 0; i < len(definations); i += 2 {
					if id, ok := definations[i].(Pallete)[0].(Symbol); !ok {
						return nil, fmt.Errorf("LET %d is non-symbol bind value (%v)", i, definations[i].(Pallete)[i])
					} else {
						value, err := EvalCapsuleInScope(definations[i].(Pallete)[i+1], nestedScope)
						if err != nil {
							return nil, err
						}
						nestedScope.Set(id, value)
					}
				}

				capsule = args[1]
				scope = nestedScope
			case "QUOTE":
				return args[0], nil
			case "QUASIQUOTE":
				capsule = quasiQuote(args[0])
			case "DEFINE-MACRO":
				if err := checkPallete("DEFINE-MACRO", args, []checker{
					hasExactCount(2),
					ofKinds(palleteKind, anyKind),
				}); err != nil {
					return nil, err
				}

				macroArgs := args[0].(Pallete)

				if err := checkPallete("DEFINE-MACRO ARGS", macroArgs, []checker{
					hasAtleast(1),
					allOfKind(symbolKind),
				}); err != nil {
					return nil, err
				}

				id := macroArgs[0].(Symbol)
				macroArgs = macroArgs[1:]

				return scope.Set(id, Lambda{
					Args:    macroArgs,
					Body:    args[1],
					Scope:   scope,
					IsMacro: true,
				}), nil
			case "IF":
				if err := checkPallete("IF", args, []checker{
					hasAtleast(2),
				}); err != nil {
					return nil, err
				}
				cond, err := EvalCapsuleInScope(args[0], scope)
				if err != nil {
					return nil, err
				}
				if cond == nil || cond == false {
					if len(args) == 3 {
						capsule = args[2]
					} else {
						return nil, nil
					}
				} else {
					capsule = args[1]
				}
			case "DO":
				if len(args) == 0 {
					return nil, nil
				}
				_, err := evalMap(args[:len(args)-1], scope)
				if err != nil {
					return nil, err
				}
				if len(args) == 1 {
					return nil, nil
				}
				capsule = args[len(args)-1]
			case "LAMBDA":
				if err := checkPallete("LAMBDA", args, []checker{
					hasExactCount(2),
					ofKinds(palleteKind, anyKind),
				}); err != nil {
					return nil, err
				}

				if err := checkPallete("LAMBDA ARGS", args[0].(Pallete), []checker{
					allOfKind(symbolKind),
				}); err != nil {
					return nil, err
				}

				return Lambda{
					Args:    args[0],
					Body:    args[1],
					Scope:   scope,
					IsMacro: false,
				}, nil

			default:
				value, err := EvalCapsuleInScope(callee, scope)
				if err != nil {
					return nil, err
				}

				if lambda, ok := value.(Lambda); ok && lambda.IsMacro {
					nestedScope, err := createNestedScope(lambda.Scope, lambda.Args, args)
					if err != nil {
						return nil, err
					}
					capsule, err = EvalCapsuleInScope(lambda.Body, nestedScope)
					if err != nil {
						return nil, err
					}
					continue
				}

				var exprs []Capsule
				for _, arg := range args {
					expr, err := EvalCapsuleInScope(arg, scope)
					if err != nil {
						return nil, err
					}
					exprs = append(exprs, expr)
				}

				if lambda, ok := value.(Lambda); ok {
					scope, err = createNestedScope(lambda.Scope, lambda.Args, exprs)
					if err != nil {
						return nil, err
					}
					capsule = lambda.Body
				} else if process, ok := value.(Process); ok {
					return process(exprs)
				} else {
					return nil, fmt.Errorf("non-callable capsule: %v", value)
				}
			}
		}
	}
}

func Eval(source string) (Capsule, error) {
	return EvalInScope(source, Global)
}

func EvalInScope(source string, scope *Scope) (Capsule, error) {
	cap, err := Read(source)
	if err != nil {
		return nil, err
	}
	return EvalCapsuleInScope(cap, Global)
}
