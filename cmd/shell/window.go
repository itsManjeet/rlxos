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
	"strconv"

	"rlxos.dev/api/shell"
)

func addWindow(args []string) error {
	f := flag.NewFlagSet("add-window", flag.ContinueOnError)
	width := f.Int("width", 500, "width of window")
	height := f.Int("height", 300, "height of window")
	if err := f.Parse(args); err != nil {
		return err
	}

	var reply shell.AddWindowReply
	if err := conn.Call("AddWindow", &shell.AddWindowArgs{
		Width:  *width,
		Height: *height,
	}, &reply); err != nil {
		return err
	}

	fmt.Println(reply.Key)

	return nil
}

func removeWindow(args []string) error {
	f := flag.NewFlagSet("remove-window", flag.ContinueOnError)
	if err := f.Parse(args); err != nil {
		return err
	}
	if f.NArg() != 1 {
		return fmt.Errorf("no key provided")
	}

	key, err := strconv.Atoi(f.Arg(0))
	if err != nil {
		return err
	}

	return conn.Call("RemoveWindow", &shell.RemoveWindowArgs{
		Key: key,
	}, &shell.RemoveWindowReply{})
}
