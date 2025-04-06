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
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"time"
)

type Manager struct {
	services     []*Service
	waitGroup    sync.WaitGroup
	running      []*Service
	Journal      *os.File
	ShuttingDown bool
}

func NewManager(journal *os.File) *Manager {
	return &Manager{
		services:     make([]*Service, 0),
		Journal:      journal,
		ShuttingDown: false,
	}
}

func (m *Manager) AddService(service *Service) *Service {
	m.services = append(m.services, service)
	return service
}

func (m *Manager) LoadServices(paths ...string) {
	for _, path := range paths {
		services, err := os.ReadDir(path)
		if err != nil {
			m.Log("failed to read services path %s: %v", path, err)
			continue
		}
		for _, serviceFile := range services {
			if serviceFile.IsDir() || filepath.Ext(serviceFile.Name()) != ".service" {
				continue
			}

			var service *Service

			service, err = NewService(filepath.Join(path, serviceFile.Name()))
			if err != nil {
				m.Log("failed to load service %s: %v", serviceFile.Name(), err)
				continue
			}

			if !service.isTemplate {
				m.services = append(m.services, service)
			}
		}
	}
}

func (m *Manager) Get(id string) *Service {
	for _, service := range m.services {
		if service.Name == id {
			return service
		}
	}
	return nil
}

func (m *Manager) Foreach(f func(s *Service)) {
	for _, service := range m.services {
		f(service)
	}
}

func (m *Manager) Log(id, format string, args ...interface{}) {
	_, _ = fmt.Fprintf(m.Journal, "["+id+"]:"+format+"\n", args...)
}

func (m *Manager) Wait() {
	m.waitGroup.Wait()
}

func (m *Manager) TriggerStage(stage string) {
	var stageWaitGroup sync.WaitGroup
	m.Foreach(func(s *Service) {
		if s.Stage != stage {
			return
		}
		stageWaitGroup.Add(1)

		go func() {
			defer stageWaitGroup.Done()

			if err := m.waitForDepends(s); err != nil {
				s.State = Failed
				return
			}

			m.Log("Starting", s.Name)

			if err := s.Start(m.Journal); err != nil {
				m.Log("failed to start", s.Name, err)
			}

			if s.Kind == Oneshot {
				if s.Process == nil {
					return
				}
				if _, err := s.Process.Wait(); err != nil {
					m.Log("failed to wait for service %s: %v", s.Name, err)
				}
				return
			}

			// TODO: better way to wait for daemon?
			time.Sleep(time.Millisecond * 50)

			m.waitGroup.Add(1)
			counter := 0
			go func() {
				defer m.waitGroup.Done()
				for {
					if s.Process == nil {
						m.Log("failed to wait for service %s: %v", s.Name, "no process created")
						s.State = Failed
						counter++
					} else {
						if _, err := s.Process.Wait(); err != nil {
							m.Log("failed to wait for service %s: %v", s.Name, err)
							s.State = Failed
							counter++
						} else {
							m.Log("Service %s finished successfully", s.Name)
							s.State = Finished
							counter = 0
						}

					}

					if m.ShuttingDown || counter > 10 || !s.Restart {
						break
					}
					m.Log("Restarting service %s", s.Name)
					time.Sleep(time.Second * 1)

					if err := s.Start(m.Journal); err != nil {
						m.Log("failed to start", s.Name, err)
					}

				}
			}()
		}()
	})
	stageWaitGroup.Wait()
}

func (m *Manager) waitForDepends(s *Service) error {
	if s.Depends == nil {
		return nil
	}

	var services []*Service
	for _, sv := range s.Depends {
		svc := m.Get(sv)
		if svc == nil {
			return fmt.Errorf("missing required dependency %s", sv)
		}
		services = append(services, svc)
	}

	timeout := time.After(10 * time.Second)
	tick := time.Tick(500 * time.Millisecond)

	for {
		select {
		case <-timeout:
			return fmt.Errorf("wait timeout")
		case <-tick:
			for i, sv := range services {
				if sv.State == Running || sv.State == Finished {
					services = append(services[:i], services[i+1:]...)
				} else if sv.State == Failed {
					return fmt.Errorf("%s dependency %s failed to start", s.Name, sv.Name)
				}
			}

			if len(services) == 0 {
				return nil
			}
		}
	}
}
