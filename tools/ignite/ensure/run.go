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

package ensure

import (
	"log"
	"os"
	"os/exec"
	"path/filepath"
)

func Always(fun func() error) {
	if err := fun(); err != nil {
		log.Fatal(err)
	}
}

func If(b bool, fun func() error) {
	if b {
		Always(fun)
	}
}

func IfExists(file string, fun func() error) {
	if _, err := os.Stat(file); err == nil {
		Always(fun)
	}
}

func Target(target string, fun func() error) {
	if _, err := os.Stat(target); err != nil {
		if target != "" {
			log.Println("TARGET", target)
		}
		Always(fun)
	}
}

func Path(path ...string) {
	for _, p := range path {
		Target(p, func() error {
			return os.MkdirAll(p, 0755)
		})
	}

}

func Success(err error) {
	if err != nil {
		log.Fatal(err)
	}
}

func Command(target string, cmd *exec.Cmd) {
	Target(target, func() (err error) {
		if !filepath.IsAbs(cmd.Args[0]) {
			cmd.Args[0], err = exec.LookPath(cmd.Args[0])
			if err != nil {
				return err
			}
		}
		cmd.Path = cmd.Args[0]
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin
		cmd.Stderr = os.Stderr
		log.Println("COMMAND", cmd.Args)
		return cmd.Run()
	})
}

func CommandTracked(target string, cmd *exec.Cmd) {
	Command(target, cmd)
	if err := os.WriteFile(target, []byte("DONE"), 0644); err != nil {
		log.Fatal(err)
	}
}

func Run(args ...string) {
	Command("", &exec.Cmd{Args: args})
}

func RunAt(path string, args ...string) {
	Command("", &exec.Cmd{Args: args, Dir: path})
}

func Foreach(ls []string, fun func(string) error) {
	for _, s := range ls {
		Always(func() error {
			return fun(s)
		})
	}
}
