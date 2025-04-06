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
	"log"
	"os"
	"syscall"
)

var (
	poweroff bool
	reboot   bool
)

func init() {
	flag.BoolVar(&poweroff, "off", false, "Power off device")
	flag.BoolVar(&reboot, "reboot", false, "Reboot device")
}

func main() {
	flag.Parse()

	var signal os.Signal

	if poweroff {
		signal = syscall.SIGUSR2
	} else if reboot {
		signal = syscall.SIGINT
	}

	if signal != nil {
		init, err := os.FindProcess(1)
		if err != nil {
			log.Fatal("no PID 1 found")
		}
		if err := init.Signal(signal); err != nil {
			log.Fatal("failed to send signal to PID 1", err)
		}
	}
}
