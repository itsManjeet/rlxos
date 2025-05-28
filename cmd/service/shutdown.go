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
	"os"
	"syscall"
)

func shutdown(args []string) error {
	f := flag.NewFlagSet("shutdown", flag.ContinueOnError)
	reboot := f.Bool("reboot", false, "Reboot system")
	if err := f.Parse(args); err != nil {
		return err
	}

	init, err := os.FindProcess(1)
	if err != nil {
		return fmt.Errorf("failed to find init process %v", err)
	}

	s := syscall.SIGUSR2
	if *reboot {
		s = syscall.SIGINT
	}
	return init.Signal(s)
}
