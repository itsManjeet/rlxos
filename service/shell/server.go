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
	"image"
	"log"
	"slices"
	"sync"

	"rlxos.dev/api/display"
	"rlxos.dev/api/shell"
	"rlxos.dev/pkg/connect"
	"rlxos.dev/pkg/kernel/input"
	"rlxos.dev/pkg/kernel/shm"
	"rlxos.dev/service/shell/window"
)

type Server struct {
	display    *connect.Connection
	input      *input.Manager
	background *shm.Image
	windows    []*window.Window
	panel      *Panel
	mutex      sync.Mutex
	cursor     image.Point
}

func (s *Server) update() {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	events, err := s.input.PollEvents()
	var activeWindow *window.Window
	if len(s.windows) > 0 {
		activeWindow = s.windows[len(s.windows)-1]
	}

	if err == nil {
		for _, event := range events {
			switch event := event.(type) {
			case input.KeyEvent:
				if event.Pressed {
					switch event.Code {
					case input.KEY_P:
						log.Println("ADDED NEW Window")
						win, err := window.NewWindow(0, 0, 600, 400)
						if err == nil {
							s.windows = append(s.windows, win)
						}
					case input.KEY_LEFT:
						if activeWindow != nil {
							pos := activeWindow.Position()
							activeWindow.SetPosition(image.Pt(pos.X-10, pos.Y))
						}

					case input.KEY_RIGHT:
						if activeWindow != nil {
							pos := activeWindow.Position()
							activeWindow.SetPosition(image.Pt(pos.X+10, pos.Y))
						}
					case input.KEY_UP:
						if activeWindow != nil {
							pos := activeWindow.Position()
							activeWindow.SetPosition(image.Pt(pos.X, pos.Y-10))
						}
					case input.KEY_DOWN:
						if activeWindow != nil {
							pos := activeWindow.Position()
							activeWindow.SetPosition(image.Pt(pos.X, pos.Y+10))
						}
					case input.KEY_TAB:
						if len(s.windows) > 1 {
							topWindow := s.windows[0]
							s.windows = s.windows[1:len(s.windows)]
							s.windows = append(s.windows, topWindow)
						}
					}
				}
			case input.CursorEvent:
				s.cursor.X += event.X
				s.cursor.Y += event.Y
			default:
				log.Println("EVENT:", event)
			}
		}
	} else {
		log.Println("failed to poll event", err)
	}
	s.panel.Update()
}

func (s *Server) render() {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	// var size display.SizeReply
	// if resp, err := s.bus.Call(display.ID+".Size", display.SizeArgs{}); err != nil {
	// 	log.Fatal(err)
	// } else {
	// 	size = resp.(display.SizeReply)
	// }

	if err := s.display.Call("Upload", display.UploadArgsFromImage(s.background, image.Pt(0, 0)), &display.UploadReply{}); err != nil {
		log.Fatal("display upload failed:", err)
	}

	for _, win := range s.windows {
		if err := s.display.Call("Upload", display.UploadArgsFromImage(win.Image(), win.Position()), &display.UploadReply{}); err != nil {
			log.Fatal("display upload failed:", err)
		}
	}

	// s.display.Call("Upload", display.UploadArgsFromImage(s.panel.img, image.Pt(0, 0)), &display.UploadReply{})

	if err := s.display.Call("Sync", &display.SyncArgs{}, &display.SyncReply{}); err != nil {
		log.Fatal("display sync failed:", err)
	}
}

func (s *Server) AddWindow(args shell.AddWindowArgs) (shell.AddWindowReply, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	win, err := window.NewWindow(args.X, args.Y, args.Width, args.Height)
	if err != nil {
		return shell.AddWindowReply{}, err
	}
	s.windows = append(s.windows, win)

	return shell.AddWindowReply{Key: win.Image().Key()}, nil
}

func (s *Server) RemoveWindow(args shell.RemoveWindowArgs) (shell.RemoveWindowReply, error) {
	s.mutex.Lock()
	defer s.mutex.Unlock()

	idx := slices.IndexFunc(s.windows, func(w *window.Window) bool {
		log.Println("Got KEY:", w.Image().Key(), "!=", args.Key)
		return w.Image().Key() == args.Key
	})
	if idx == -1 {
		return shell.RemoveWindowReply{}, fmt.Errorf("no window with key %v", args.Key)
	}
	s.windows[idx].Destroy()
	s.windows = append(s.windows[:idx], s.windows[idx+1:]...)

	return shell.RemoveWindowReply{}, nil
}
