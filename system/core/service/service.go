package service

import (
	"os"
	"os/exec"
	"os/user"
	"strconv"
	"syscall"

	"gopkg.in/yaml.v3"
)

type Kind string

const (
	OneShot Kind = "oneshot"
	Daemon  Kind = "daemon"
)

type Service struct {
	Description string   `yaml:"description"`
	Kind        Kind     `yaml:"kind"`
	Exec        string   `yaml:"exec"`
	Args        []string `yaml:"args"`
	Restart     bool     `yaml:"restart"`
	Environ     []string `yaml:"environ"`
	Requires    []string `yaml:"requires"`
	ExecStop    string   `yaml:"exec:stop"`
	ArgsStop    []string `yaml:"args:stop"`

	User  string `yaml:"user"`
	Group string `yaml:"group"`
	TTY   string `yaml:"tty"`
	Dir   string `yaml:"dir"`

	Process *os.Process
	status  Status
	tty     *os.File
}

func Load(filename string) (*Service, error) {
	data, err := os.ReadFile(filename)
	if err != nil {
		return nil, err
	}

	var service Service
	if err := yaml.Unmarshal(data, &service); err != nil {
		return nil, err
	}

	service.status = StatusNotStarted
	if service.User == "" {
		service.User = "root"
	}

	if service.Dir == "" {
		service.Dir = "/"
	}

	return &service, nil
}

func (s *Service) isProcessRunning() bool {
	if s.Process == nil {
		return false
	}

	if err := s.Process.Signal(syscall.Signal(0)); err == nil {
		return true
	}
	return false
}

func (s *Service) Command(bin string, args ...string) (*exec.Cmd, error) {
	path, err := exec.LookPath(bin)
	if err != nil {
		return nil, err
	}

	usr, err := user.Lookup(s.User)
	if err != nil {
		return nil, err
	}
	uid, _ := strconv.Atoi(usr.Uid)
	gid, _ := strconv.Atoi(usr.Gid)

	if s.Group != "" {
		grp, err := user.LookupGroup(s.Group)
		if err != nil {
			return nil, err
		}
		gid, _ = strconv.Atoi(grp.Gid)
	}

	return &exec.Cmd{
		Path:   path,
		Args:   append([]string{path}, args...),
		Stdin:  os.Stdin,
		Stdout: os.Stdout,
		Stderr: os.Stderr,
		Dir:    s.Dir,
		Env:    append(os.Environ(), s.Environ...),
		SysProcAttr: &syscall.SysProcAttr{
			Credential: &syscall.Credential{
				Uid: uint32(uid),
				Gid: uint32(gid),
			},
		},
	}, nil
}
