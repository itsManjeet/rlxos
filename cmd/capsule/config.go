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
	"os"
	"path/filepath"

	"rlxos.dev/pkg/capsule"
)

func loadConfig() {
	for _, path := range []string{
		filepath.Join(os.Getenv("HOME"), ".local.cap"),
		"/config/global.cap",
	} {
		source, err := os.ReadFile(path)
		if err == nil {
			_, _ = capsule.Eval(string(source))
			return
		}
	}
}
