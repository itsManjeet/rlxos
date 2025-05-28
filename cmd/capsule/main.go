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
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"rlxos.dev/pkg/capsule"

	"github.com/chzyer/readline"
)

var (
	source string
)

var completer = readline.NewPrefixCompleter()

func init() {
	flag.StringVar(&source, "source", "", "Inline source")
	registerBuiltins()
}

func main() {
	flag.Parse()

	loadConfig()

	if source != "" {
		_, err := capsule.Eval(source)
		if err != nil {
			fmt.Printf("#ERROR: %v\n", err)
			os.Exit(1)
		}
	} else if flag.NArg() != 0 {
		for _, path := range flag.Args() {
			source, err := os.ReadFile(path)
			if err != nil {
				log.Fatal(err)
			}

			if _, err := capsule.Eval("(DO \n" + string(source) + "\n)"); err != nil {
				fmt.Printf("#ERROR: %v\n", err)
				os.Exit(1)
			}
		}
	} else {
		repl()
	}
}

func filterInput(r rune) (rune, bool) {
	switch r {
	case readline.CharCtrlZ:
		return r, false
	}
	return r, true
}

func repl() {
	rl, err := readline.NewEx(&readline.Config{
		Prompt:          "> ",
		HistoryFile:     filepath.Join(os.Getenv("HOME"), ".history"),
		AutoComplete:    completer,
		InterruptPrompt: "^C",
		EOFPrompt:       "exit",

		HistorySearchFold:   true,
		FuncFilterInputRune: filterInput,
	})
	if err != nil {
		log.Fatal(err)
	}
	defer rl.Close()

	for {

		line, _ := read(rl)

		cap, err := capsule.Eval(line)
		if err != nil {
			fmt.Printf("#ERROR: %v\n", err)
			continue
		}

		if cap != nil {
			fmt.Printf(":: %v\n", capsule.ToString(cap))
		}
	}
}

func read(r *readline.Instance) (string, error) {
	prompt, err := capsule.Global.Get("PROMPT")
	if err != nil {
		prompt = "> "
	}

	r.SetPrompt(prompt.(string))
	line, err := r.Readline()
	if err != nil {
		return "", err
	}

	for {
		if isComplete(line) {
			break
		}

		r.SetPrompt("... ")
		nextLine, _ := r.Readline()
		line += " " + nextLine
	}
	return strings.Trim(line, "\n"), nil
}

func isComplete(s string) bool {
	var b []rune
	bmap := map[rune]rune{
		')': '(',
		'}': '{',
		']': '[',
	}
	for _, ch := range s {
		switch ch {
		case '(', '{', '[':
			b = append(b, ch)
		case ')', '}', ']':
			if b[len(b)-1] == bmap[ch] {
				b = b[:len(b)-1]
			} else {
				return true
			}
		}
	}
	return len(b) == 0
}
