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
	"sync"

	"rlxos.dev/api/display"
	"rlxos.dev/pkg/graphics"
)

type Server struct {
	display *Display
	mutex   sync.Mutex
}

func (s *Server) Upload(args display.UploadArgs) (display.UploadReply, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	source, err := args.GetSharedImage()
	if err != nil {
		return display.UploadReply{}, err
	}
	defer source.Detach()

	canvas := s.display.Canvas()
	graphics.Image(canvas, args.Bounds, source)

	return display.UploadReply{}, nil
}

func (s *Server) Clear(args display.ClearArgs) (display.ClearReply, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	canvas := s.display.Canvas()
	graphics.Clear(canvas, args.Color)

	return display.ClearReply{}, nil
}

func (s *Server) Sync(args display.SyncArgs) (display.SyncReply, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	s.display.Sync()

	return display.SyncReply{}, nil
}

func (s *Server) Size(args display.SizeArgs) (display.SizeReply, error) {
	return display.SizeReply{
		Width:  int(s.display.mode.Hdisplay),
		Height: int(s.display.mode.Vdisplay),
	}, nil
}
