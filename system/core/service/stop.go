package service

import (
	"fmt"
	"log"
	"syscall"
	"time"
)

func (s *Service) Stop() error {
	switch s.Kind {
	case OneShot:
		if s.ExecStop != "" {
			cmd, err := s.Command(s.ExecStop, s.ArgsStop...)
			if err != nil {
				return fmt.Errorf("failed to create command %s: %v", s.ExecStop, err)
			}
			return cmd.Run()
		}
		return nil

	case Daemon:
		if !s.isProcessRunning() && s.Kind != OneShot {
			return nil
		}

		termChannel := make(chan bool, 1)
		go func() {
			_ = s.Process.Signal(syscall.SIGTERM)
			termChannel <- true
		}()

		select {
		case <-termChannel:
			return nil
		case <-time.After(3 * time.Second):
			log.Println("termination timeout")
			if !s.isProcessRunning() {
				return s.Process.Kill()
			}
			return nil
		}

	}
	return nil
}
