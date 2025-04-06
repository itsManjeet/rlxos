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

package app

import (
	"fmt"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"

	"rlxos.dev/pkg/graphics/driver"
	"rlxos.dev/pkg/graphics/event"
	"rlxos.dev/pkg/graphics/widget"
)

type IApplication interface {
	widget.Widget

	Init(width, height int) error
	Tick() time.Duration
}

type Application struct {
}

func (a *Application) Init(width, height int) error {
	return nil
}

func (a *Application) Tick() time.Duration {
	return time.Second * 1000
}

func Run(a IApplication, drivers ...driver.Driver) error {
	if drivers == nil {
		drivers = supportedDrivers
	}

	var selectedDriver driver.Driver
	for _, d := range drivers {
		if err := d.Init(); err != nil {
			log.Printf("failed to initialize %T: %v", d, err)
			continue
		}
		selectedDriver = d
		break
	}
	if selectedDriver == nil {
		return fmt.Errorf("no supported driver initiliazed")
	}
	defer selectedDriver.Destroy()

	signalChannel := make(chan os.Signal, 1)
	signal.Notify(signalChannel, os.Interrupt, syscall.SIGTERM)

	go func() {
		<-signalChannel
		selectedDriver.Destroy()
		os.Exit(1)
	}()

	running := true
	canvas := selectedDriver.Canvas()

	if err := a.Init(canvas.Size()); err != nil {
		return err
	}

	eventChannel := make(chan event.Event, 1)
	go func() {
		for {
			ev := selectedDriver.PollEvent()
			eventChannel <- ev
		}
	}()

	ticker := time.NewTicker(a.Tick())
	defer ticker.Stop()

	for running {
		select {
		case ev := <-eventChannel:
			switch ev := ev.(type) {
			case event.Keyboard:
				if ev.Key == event.KeyAscii && ev.Rune == 'q' {
					running = false
				}
			}
			a.Update(ev)
		case <-ticker.C:
			a.Update(nil)
		}

		a.Draw(canvas)
		selectedDriver.Update()
	}

	return nil
}
