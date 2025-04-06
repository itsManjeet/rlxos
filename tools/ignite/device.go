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
	"encoding/json"
	"os"
)

type Graphics struct {
	Drivers []string `json:"drivers"`
}
type Device struct {
	ID           string   `json:"id"`
	Arch         string   `json:"arch"`
	GoArch       string   `json:"goarch"`
	TargetTriple string   `json:"target-triple"`
	Graphics     Graphics `json:"graphics"`
	Extra        []string `json:"extra"`
}

func (d *Device) LoadConfig(filename string) error {
	data, err := os.ReadFile(filename)
	if err != nil {
		return err
	}

	return json.Unmarshal(data, d)
}
