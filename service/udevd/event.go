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
	"strings"
)

type Event struct {
	Action     string
	DevicePath string
	SubSystem  string
	DeviceName string
	Properties map[string]string
}

func parseEvent(source []byte, length int) Event {
	parts := strings.Split(string(source[:length]), "\u0000")
	e := Event{
		Properties: map[string]string{},
	}

	for _, part := range parts {
		if part == "" {
			continue
		}

		keyValue := strings.SplitN(part, "=", 2)
		if len(keyValue) != 2 {
			continue
		}
		key, value := keyValue[0], keyValue[1]
		switch key {
		case "ACTION":
			e.Action = value
		case "DEVPATH":
			e.DevicePath = value
		case "SUBSYSTEM":
			e.SubSystem = value
		case "DEVNAME":
			e.DeviceName = value
		default:
			e.Properties[key] = value
		}
	}
	return e
}

func (e Event) Id() string {
	return e.DeviceName
}

func (e Event) Do() {
	if modalias, ok := e.Properties["MODALIAS"]; ok {
		_ = LoadKernelModule(modalias)
	}
}
