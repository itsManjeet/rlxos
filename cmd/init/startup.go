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
	"log"
	"os"
	"syscall"
)

const (
	JournalPath  = "/cache/log/journal"
	ServicesPath = "/config/services"
)

var (
	manager *Manager
	stages  = []string{"pre-init", "init", "post-init"}
)

func startup() {
	if _, err := os.Stat(JournalPath); err == nil {
		if err := os.Rename(JournalPath, JournalPath+".old"); err != nil {
			log.Printf("failed to replace older journal %v", err)
		}
	}
	journal, err := os.OpenFile(JournalPath, os.O_RDWR|os.O_CREATE|os.O_APPEND, 0666)
	if err != nil {
		journal = os.Stdout
	}
	manager = NewManager(journal)

	manager.LoadServices(ServicesPath)

	for _, stage := range stages {
		manager.TriggerStage(stage)
	}

	manager.TriggerStage("service")

	manager.Wait()
}

func waitForChildProcesses(options int) {
	for {
		if pid, _ := syscall.Wait4(-1, nil, options, nil); pid <= 0 {
			break
		}
	}
}
