package service

import (
	"fmt"
	"log"
	"os"
)

func (s *Service) Start() error {
	if s.isProcessRunning() {
		return nil
	}
	s.status = StatusNotStarted
	cmd, err := s.Command(s.Exec, s.Args...)
	if err != nil {
		s.status = StatusFinishedWithError
		return fmt.Errorf("failed to create command %s: %v", s.Exec, err)
	}

	switch s.Kind {
	case OneShot:
		return cmd.Run()

	case Daemon:
		if s.TTY != "" {
			s.tty, err = os.OpenFile(s.TTY, os.O_RDWR, 0)
			if err != nil {
				return fmt.Errorf("error openning tty: %v", err)
			}

			if err := os.Chown(s.TTY, int(cmd.SysProcAttr.Credential.Uid), int(cmd.SysProcAttr.Credential.Gid)); err != nil {
				return fmt.Errorf("failed to own tty: %v", err)
			}

			cmd.Stdin = s.tty
			cmd.Stdout = s.tty
			cmd.Stderr = s.tty

			cmd.SysProcAttr.Setctty = true
			cmd.SysProcAttr.Setsid = true
			cmd.SysProcAttr.Ctty = int(s.tty.Fd())
		}
		if err := cmd.Start(); err != nil {
			s.status = StatusFinishedWithError
			return fmt.Errorf("failed to start service %v", err)
		}
		s.status = StatusRunning

		go func() {
			if err := cmd.Wait(); err != nil {
				s.status = StatusFinishedWithError
				log.Println("service finished with error", err)
			} else {
				s.status = StatusFinished
			}
			if s.tty != nil {
				_ = s.tty.Close()
			}
		}()
	}

	return nil
}
