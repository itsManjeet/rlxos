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

package uevent

import "strings"

const (
	BUFFER_SIZE = 2048
)

type UEvent struct {
	Action     string
	DevicePath string
	SubSystem  string
	DeviceName string
	Properties map[string]string
}

func parseUEvent(buffer []byte, length int) (*UEvent, error) {
	parts := strings.Split(string(buffer[:length]), "\u0000")
	u := &UEvent{
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
			u.Action = value
		case "DEVPATH":
			u.DevicePath = value
		case "SUBSYSTEM":
			u.SubSystem = value
		case "DEVNAME":
			u.DeviceName = value
		default:
			u.Properties[key] = value
		}
	}

	return u, nil
}
