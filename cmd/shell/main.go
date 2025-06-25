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
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"os/signal"
	"strconv"
	"strings"
	"syscall"
)

var (
	builtins = map[string]func([]string) error{
		"cd":     cd,
		"ls":     ls,
		"exit":   exit,
		"cat":    cat,
		"export": export,
		"echo":   echo,
		"clear":  clear,
	}
)

func main() {
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)

	rl := bufio.NewReader(os.Stdin)

	for {
		fmt.Print("> ")
		input, err := rl.ReadString('\n')
		if err != nil {
			_, _ = fmt.Fprintln(os.Stderr, err)
			continue
		}

		args := strings.Split(os.ExpandEnv(strings.TrimSuffix(input, "\n")), " ")
		if len(args) == 0 {
			continue
		}

		builtin, ok := builtins[args[0]]
		if ok {
			err = builtin(args[1:])
		} else {
			cmd := exec.Command(args[0], args[1:]...)
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr
			cmd.Stdin = os.Stdin

			cmd.SysProcAttr = &syscall.SysProcAttr{
				Setpgid: true,
			}

			if err = cmd.Start(); err == nil {
				go func(pid int) {
					for sig := range sigChan {
						_ = syscall.Kill(-pid, sig.(syscall.Signal))
					}
				}(cmd.Process.Pid)

				err = cmd.Wait()
			}
		}

		if err != nil {
			fmt.Printf("ERROR: %v\n", err)
		}
	}
}

func exit(args []string) (err error) {
	code := 0
	if len(args) != 0 {
		code, err = strconv.Atoi(args[0])
		if err != nil {
			return err
		}
	}
	os.Exit(code)
	return fmt.Errorf("failed to exit to process")
}
