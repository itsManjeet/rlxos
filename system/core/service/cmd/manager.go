package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"rlxos/system/core/service"
)

const (
	SystemServicesPath = "/config/services"
)

type Manager struct {
	services map[string]*service.Service
}

func NewManager(servicesPaths ...string) (*Manager, error) {
	services := map[string]*service.Service{}
	for _, servicesPath := range servicesPaths {
		dir, err := os.ReadDir(servicesPath)
		if err != nil {
			log.Println("failed to read", servicesPath, err)
			continue
		}

		for _, file := range dir {
			if file.IsDir() || filepath.Ext(file.Name()) != ".yml" {
				continue
			}
			s, err := service.Load(filepath.Join(servicesPath, file.Name()))
			if err != nil {
				log.Println("failed to load service", file.Name(), err)
				continue
			}
			services[file.Name()[:len(file.Name())-4]] = s
		}
	}

	return &Manager{services: services}, nil
}

func (m *Manager) Foreach(f func(s *service.Service) error) error {
	sortedServices, err := sort(m.services, "Requires")
	if err != nil {
		return err
	}
	for _, s := range sortedServices {
		if err := f(s); err != nil {
			return err
		}
	}
	return nil
}

func sort(sl map[string]*service.Service, id string) ([]*service.Service, error) {
	inDegree := map[string]int{}
	dependencies := map[string][]string{}

	for id, v := range sl {
		if _, exists := inDegree[id]; !exists {
			inDegree[id] = 0
		}

		for _, req := range v.Requires {
			inDegree[id] += 1
			dependencies[req] = append(dependencies[req], id)
		}
	}

	var queue []string
	for id, degree := range inDegree {
		if degree == 0 {
			queue = append(queue, id)
		}
	}

	var sortedSlice []*service.Service
	for len(queue) > 0 {
		id := queue[0]
		queue = queue[1:]
		sortedSlice = append(sortedSlice, sl[id])

		for _, req := range dependencies[id] {
			inDegree[id] -= 1
			if inDegree[id] <= 0 {
				queue = append(queue, req)
			}
		}
	}

	if len(sortedSlice) != len(sl) {
		return nil, fmt.Errorf("found circular dependencies")
	}
	return sortedSlice, nil
}
