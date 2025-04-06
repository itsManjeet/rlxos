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
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/chzyer/readline"
)

func main() {
	_ = os.Setenv("SHELL", os.Args[0])
	reader, err := readline.NewEx(&readline.Config{
		Prompt:            "» ",
		HistoryFile:       filepath.Join(os.Getenv("HOME"), ".shell_history"),
		InterruptPrompt:   "^C",
		AutoComplete:      completer,
		EOFPrompt:         "exit",
		HistorySearchFold: true,
	})
	if err != nil {
		log.Fatal(err)
	}
	defer reader.Close()

	reader.CaptureExitSignal()
	for {
		line, err := reader.Readline()
		if err == readline.ErrInterrupt {
			if len(line) == 0 {
				break
			} else {
				continue
			}
		} else if err == io.EOF {
			break
		}
		line = os.ExpandEnv(line)
		args := strings.Fields(line)
		if len(args) == 0 {
			continue
		}

		b, ok := builtins[args[0]]
		if ok {
			if err := b(args[1:]); err != nil {
				fmt.Print("ERROR", err)
			}
			_ = os.Setenv("?", "1")
		} else {
			cmd := exec.Command(args[0], args[1:]...)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			cmd.Stdin = os.Stdin
			if err := cmd.Run(); err != nil {
				fmt.Println("ERROR", err)
			}
			_ = os.Setenv("?", fmt.Sprint(cmd.ProcessState.ExitCode()))
		}
	}
}
