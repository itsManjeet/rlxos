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
	"fmt"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
	"strconv"
	"strings"
	"syscall"
)

type Kind string

const (
	Oneshot Kind = "oneshot"
	Daemon  Kind = "daemon"
)

type State int

const (
	NotStarted State = iota
	Started
	Running
	Finished
	Failed
)

type Service struct {
	Stage        string   `json:"stage"`
	Kind         Kind     `json:"kind"`
	Description  string   `json:"description"`
	ExecStart    string   `json:"exec-start"`
	ExecStop     string   `json:"exec-stop"`
	Depends      []string `json:"depends"`
	Prepare      []string `json:"prepare"`
	Cleanup      []string `json:"cleanup"`
	TTY          string   `json:"tty"`
	Restart      bool     `json:"restart"`
	Environ      []string `json:"environ"`
	User         string   `json:"user"`
	Group        string   `json:"group"`
	Groups       []string `json:"groups"`
	IfPathExists string   `json:"if-path-exists"`

	Name       string      `json:"-"`
	Process    *os.Process `json:"-"`
	State      State       `json:"-"`
	isTemplate bool
}

func NewService(filename string) (*Service, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	// TODO: Fix this
	base := strings.TrimSuffix(filepath.Base(filename), filepath.Ext(filename))
	var isTemplate bool
	if idx := strings.Index(base, "@"); idx != -1 {
		if idx == len(base)-1 {
			isTemplate = true
		} else {
			data = []byte(strings.ReplaceAll(string(data), "%i", base[idx+1:]))
		}
	}
	var service Service
	if err := json.Unmarshal(data, &service); err != nil {
		return nil, err
	}
	if service.Stage == "" {
		service.Stage = "service"
	}
	if service.Kind == "" {
		service.Kind = Daemon
	}
	service.Name = filepath.Base(filename)
	service.Name = strings.TrimSuffix(service.Name, filepath.Ext(service.Name))

	service.State = NotStarted
	service.isTemplate = isTemplate
	return &service, nil
}

func (s *Service) isProcessRunning() bool {
	if s.Process == nil {
		return false
	}
	return s.Process.Signal(syscall.Signal(0)) == nil
}

func (s *Service) Stop(journal *os.File) error {
	if s.Kind == Daemon && !s.isProcessRunning() && s.ExecStop == "" {
		return nil
	}

	if s.ExecStop == "" {
		// TODO: we should gave process time to wait and finish by itself
		return s.Process.Kill()
	}

	args := strings.Split(s.ExecStop, " ")
	if len(args) == 0 {
		return fmt.Errorf("no command to execute")
	}

	cmd := exec.Command(args[0], args[1:]...)
	cmd.Stdout = journal
	cmd.Stderr = journal

	if err := cmd.Run(); err != nil {
		return err
	}
	s.State = Finished
	s.Process = nil
	return nil
}

func (s *Service) Start(journal *os.File) error {
	if s.isProcessRunning() {
		return nil
	}

	if s.IfPathExists != "" {
		if _, err := os.Stat(s.IfPathExists); err != nil {
			s.State = NotStarted
			return nil
		}
	}

	s.State = NotStarted
	args := strings.Split(s.ExecStart, " ")
	if len(args) == 0 {
		return fmt.Errorf("no command to execute")
	}

	uid, gid := 0, 0
	var groups []uint32

	env := append(os.Environ(), s.Environ...)
	if s.User != "" {
		usr, err := user.Lookup(s.User)
		if err != nil {
			return err
		}
		uid, err = strconv.Atoi(usr.Uid)
		if err != nil {
			return err
		}
		gid, err = strconv.Atoi(usr.Gid)
		if err != nil {
			return err
		}

		groupIds, err := usr.GroupIds()
		if err != nil {
			return err
		}

		for _, grp := range groupIds {
			grpId, err := strconv.Atoi(grp)
			if err != nil {
				return err
			}
			groups = append(groups, uint32(grpId))
		}
		env = append(env, "HOME="+usr.HomeDir)
	}

	if s.Group != "" {
		grp, err := user.LookupGroup(s.Group)
		if err != nil {
			return err
		}
		gid, err = strconv.Atoi(grp.Gid)
		if err != nil {
			return err
		}
	}

	for _, grpName := range s.Groups {
		grp, err := user.LookupGroup(grpName)
		if err != nil {
			return err
		}
		grpId, err := strconv.Atoi(grp.Gid)
		if err != nil {
			return err
		}
		groups = append(groups, uint32(grpId))
	}

	for _, p := range s.Prepare {
		for key, value := range map[string]any{
			"%u": uid,
			"%g": gid,
		} {
			p = strings.ReplaceAll(p, key, fmt.Sprint(value))
		}
		pa := strings.Split(p, " ")
		if len(pa) == 0 {
			continue
		}

		switch pa[0] {
		case "export":
			env = append(env, pa[1:]...)
		default:
			if output, err := exec.Command(pa[0], pa[1:]...).CombinedOutput(); err != nil {
				return fmt.Errorf("failed to prepare %s %v", string(output), err)
			}
		}

	}

	cmd := exec.Command(args[0], args[1:]...)
	if s.TTY != "" {
		env = append(env, "TTY="+s.TTY)
		if err := os.Chown(s.TTY, uid, gid); err != nil {
			return err
		}
		tty, err := os.OpenFile(s.TTY, os.O_RDWR, 0)
		if err != nil {
			return err
		}
		cmd.Stdin = tty
		cmd.Stderr = tty
		cmd.Stdout = tty
	} else {
		cmd.Stdout = journal
		cmd.Stderr = journal
	}
	cmd.Env = env
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Credential: &syscall.Credential{
			Uid:    uint32(uid),
			Gid:    uint32(gid),
			Groups: groups,
		},
		Setsid: true,
	}

	if err := cmd.Start(); err != nil {
		s.State = Failed
		return err
	}
	s.State = Running
	s.Process = cmd.Process
	return nil
}
