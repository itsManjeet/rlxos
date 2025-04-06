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
	"strings"

	"github.com/chzyer/readline"
)

var (
	completer  *readline.PrefixCompleter
	completers []readline.PrefixCompleterInterface
)

func init() {
	for _, path := range strings.Split(os.Getenv("PATH"), ":") {
		binaries, err := os.ReadDir(path)
		if err == nil {
			for _, bin := range binaries {
				completers = append(completers, readline.PcItem(bin.Name()))
			}
		}
	}
	completer = readline.NewPrefixCompleter(completers...)
}
