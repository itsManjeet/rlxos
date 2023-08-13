package service

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"

	"gopkg.in/yaml.v2"
)

type State int

const (
	NotStarted State = iota
	Started
	Stopped
	InProcess
	Finished
	Error
)

type Service struct {
	Id        string   `yaml:"id"`
	ExecStart string   `yaml:"start"`
	ExecStop  string   `yaml:"stop"`
	Depends   []string `yaml:"depends"`

	State State
}

func Open(filepath string) (*Service, error) {
	data, err := os.ReadFile(filepath)
	if err != nil {
		return nil, fmt.Errorf("failed to read file %s, %v", filepath, err)
	}

	var service Service
	if err := yaml.Unmarshal(data, &service); err != nil {
		return nil, fmt.Errorf("failed to parse file %s, %v", filepath, err)
	}

	return &service, nil
}

func (s *Service) Start() error {
	if s.State == InProcess || s.State == Started {
		return fmt.Errorf("already started")
	}

	s.State = InProcess
	data := strings.Split(s.ExecStart, " ")
	if len(data) == 0 {
		return fmt.Errorf("invalid service command %s", s.ExecStart)
	}
	cmd := exec.Command(data[0], data[1:]...)
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		s.State = Error
		return err
	}
	s.State = Started
	return nil
}

func (s *Service) DependSatisfied(started map[string]bool, mutex *sync.RWMutex) bool {
	mutex.RLock()
	defer mutex.RUnlock()

	for _, depend := range s.Depends {
		if !started[depend] {
			return false
		}
	}
	return true
}
