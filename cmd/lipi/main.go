package main

import (
	"flag"
	"fmt"
	"os"
	"strings"

	"rlxos.dev/pkg/lipi"
	"rlxos.dev/pkg/readline"
)

var (
	inline bool
)

func init() {
	flag.BoolVar(&inline, "i", false, "inline script")
}

func main() {
	flag.Parse()

	if flag.NArg() == 0 {
		repl()
		return
	}

	for _, arg := range flag.Args() {
		if inline {
			_, err := lipi.Eval(arg)
			if err != nil {
				_, _ = fmt.Fprintf(os.Stderr, "ERROR: %v", err)
				os.Exit(1)
			}
		} else {
			data, err := os.ReadFile(arg)
			if err != nil {
				_, _ = fmt.Fprintf(os.Stderr, "ERROR: %v", err)
				os.Exit(1)
			}

			_, err = lipi.Eval(string(data))
			if err != nil {
				_, _ = fmt.Fprintf(os.Stderr, "ERROR: %v", err)
				os.Exit(1)
			}
		}
	}
}

func repl() {
	reader := readline.NewReader("> ")

	for {
		// prompt, err := lipi.Global.Get("PROMPT")
		// if err != nil {
		// 	prompt = "> "
		// }
		reader.SetPrompt("> ")

		line, err := reader.Readline()
		if err != nil {
			if err.Error() == "EOF" {
				break
			}
			_, _ = fmt.Fprintf(os.Stderr, "ERROR: %v", err)
			continue
		}

		for !isBalanced(line) {
			reader.SetPrompt("...")
			subline, err := reader.Readline()
			if err != nil {
				_, _ = fmt.Fprintf(os.Stderr, "ERROR: %v", err)
				os.Exit(1)
			}

			line += " " + subline
		}

		line = strings.TrimSpace(line)
		if len(line) == 0 {
			continue
		}

		if line[0] != '(' {
			line = "(" + line + ")"
		}
		result, err := lipi.Eval(line)
		if err != nil {
			fmt.Printf("ERROR: %v\n", err)
			continue
		}

		if result != nil {
			fmt.Println("::", lipi.ToString(result))
		}
	}
}

func isBalanced(s string) bool {
	brackets := map[rune]rune{
		'(': ')',
		'{': '}',
		'[': ']',
	}
	var stack []rune
	for _, c := range s {
		switch c {
		case '(', '{', '[':
			stack = append(stack, c)
		case ')', '}', ']':
			if len(stack) == 0 {
				// This is error situation but let lipi handle it with
				// detailed error info
				return true
			}
			if stack[len(stack)-1] == brackets[c] {
				stack = stack[:len(stack)-1]
			} else {
				// Again error situation but let lipi handle it
				return true
			}
		}
	}
	return len(stack) == 0
}
