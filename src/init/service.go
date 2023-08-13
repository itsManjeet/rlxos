package main

import (
	"io/ioutil"
	"log"
	"path"
	"rlxos/src/init/service"
	"sync"
	"time"
)

func startAllServices() {
	var services []*service.Service

	dir, err := ioutil.ReadDir(getConfig("rd.service.dir", "/lib/services"))
	if err != nil {
		log.Println("failed to read service dir,", err)
		return
	}

	for _, file := range dir {
		if file.IsDir() {
			continue
		}

		ser, err := service.Open(path.Join(getConfig("rd.service.dir", "/lib/services"), file.Name()))
		if err != nil {
			log.Println(err)
		}

		services = append(services, ser)
	}

	waitGroup := sync.WaitGroup{}
	mutex := &sync.RWMutex{}
	started := map[string]bool{}

	waitGroup.Add(len(services))
	for _, ser := range services {
		go func(s *service.Service) {
			for satisfied, tries := false, 0; !satisfied && tries < 60; tries++ {
				satisfied = s.DependSatisfied(started, mutex)
				time.Sleep(2 * time.Second)
			}

			if s.State == service.NotStarted {
				if err := s.Start(); err != nil {
					log.Println(err)
				}
			}
			mutex.Lock()
			started[s.Id] = true
			mutex.Unlock()
			waitGroup.Done()
		}(ser)
	}

	waitGroup.Wait()
}
