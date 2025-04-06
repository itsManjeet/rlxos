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
	"context"
	"log"
	"os"
	"os/signal"
	"slices"
	"syscall"

	"rlxos.dev/tools/ignite/ensure"
)

func main() {
	if isInsideInitrd() {
		ensure.Success(switchToRealRoot())
	}

	ensure.Success(os.Setenv("PATH", "/cmd:/service:/usr/bin:/usr/sbin"))
	ensure.Success(os.Setenv("XDG_CONFIG_DIRS", "/config:/etc/xdg"))
	ensure.Success(os.Setenv("XDG_DATA_DIRS", "/data:/usr/share"))

	ctxt, cancel := context.WithCancel(context.Background())

	go func() {
		defer cancel()

		startup()
	}()

	_ = syscall.Reboot(syscall.LINUX_REBOOT_CMD_CAD_OFF)

	signalChannel := make(chan os.Signal, 4)
	signal.Notify(signalChannel,
		syscall.SIGUSR1,
		syscall.SIGUSR2,
		syscall.SIGCHLD,
		syscall.SIGINT,
		syscall.SIGTERM)
	var rebootCommand int
	for rebootCommand == 0 {
		select {
		case sig := <-signalChannel:
			switch sig {
			case syscall.SIGUSR1:
				rebootCommand = syscall.LINUX_REBOOT_CMD_KEXEC

			case syscall.SIGUSR2:
				rebootCommand = syscall.LINUX_REBOOT_CMD_POWER_OFF

			case syscall.SIGINT, syscall.SIGTERM:
				rebootCommand = syscall.LINUX_REBOOT_CMD_RESTART

			case syscall.SIGCHLD:
				waitForChildProcesses(syscall.WNOHANG)

			}
		case <-ctxt.Done():
			rebootCommand = syscall.LINUX_REBOOT_CMD_POWER_OFF
		}

	}

	manager.ShuttingDown = true

	manager.Foreach(stopService(func(s *Service) bool {
		return s.Stage == "service"
	}))

	reverseStages := slices.Clone(stages)
	slices.Reverse(reverseStages)

	for _, stage := range reverseStages {
		manager.Foreach(stopService(func(s *Service) bool {
			return s.Stage == stage
		}))
	}

	manager.TriggerStage("shutdown")

	_ = syscall.Reboot(syscall.LINUX_REBOOT_CMD_CAD_ON)
	syscall.Sync()

	if rebootCommand == 0 {
		rebootCommand = syscall.LINUX_REBOOT_CMD_POWER_OFF
	}

	log.Println("syscall::reboot():", rebootCommand)
	ensure.Success(syscall.Reboot(rebootCommand))
}

func stopService(cond func(s *Service) bool) func(s *Service) {
	return func(s *Service) {
		if cond(s) {
			log.Println("Stopping", s.Name)
			if err := s.Stop(manager.Journal); err != nil {
				log.Println("failed to stop", s.Name, err)
			}
		}
	}
}
