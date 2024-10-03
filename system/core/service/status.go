package service

import (
	"encoding/gob"
)

type Status int

const (
	StatusUnknown Status = iota
	StatusNotStarted
	StatusRunning
	StatusFinished
	StatusFinishedWithError
)

func init() {
	gob.Register(Status(0))
}

func (s Status) String() string {
	switch s {
	case StatusUnknown:
		return "unknown"
	case StatusNotStarted:
		return "not yet started"
	case StatusRunning:
		return "running"
	case StatusFinished:
		return "finished"
	case StatusFinishedWithError:
		return "failed"
	}
	return "invalid"
}

func (s *Service) Status() Status {
	return s.status
}
