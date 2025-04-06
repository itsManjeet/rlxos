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
	"bufio"
	"flag"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

const (
	PASSWD_FILE = "/etc/passwd"
)

const (
	USERNAME_FIELD int = iota
	X_FIELD
	UID_FIELD
	GID_FIELD
	COMMENT_FIELD
	HOME_DIR_FIELD
	SHELL_FIELD
)

var (
	root string
)

func init() {
	flag.StringVar(&root, "root", "/", "Specify root directory")
}

func main() {
	flag.Parse()

	if err := ensureUsers(); err != nil {
		log.Fatal(err)
	}
}

func ensureUsers() error {
	file, err := os.OpenFile(filepath.Join(root, PASSWD_FILE), os.O_RDONLY, 0)
	if err != nil {
		return err
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	for scanner.Scan() {
		line := scanner.Text()
		user := strings.Split(line, ":")
		if len(user) != 7 {
			continue
		}
		username := user[USERNAME_FIELD]
		homedir := filepath.Join(root, user[HOME_DIR_FIELD])
		// shell := user[SHELL_FIELD]
		uid, err := strconv.Atoi(user[UID_FIELD])
		if err != nil {
			log.Printf("invalid user id for %s, %s", username, user[UID_FIELD])
			continue
		}

		gid, err := strconv.Atoi(user[GID_FIELD])
		if err != nil {
			log.Printf("invalid groupd id for %s, %s", username, user[GID_FIELD])
			continue
		}

		if _, err := os.Stat(homedir); err != nil {
			if err := os.MkdirAll(filepath.Dir(homedir), 0755); err != nil {
				log.Printf("failed to create homedir %s for %s %v", homedir, user, err)
				continue
			}

			if err := os.Mkdir(homedir, 0750); err != nil {
				log.Printf("failed to create homedir %s for %s %v", homedir, user, err)
				continue
			}

			if err := os.Chown(homedir, uid, gid); err != nil {
				log.Printf("failed to chown homedir %s for %s %v", homedir, user, err)
				continue
			}
		}
	}

	return nil
}
