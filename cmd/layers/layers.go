package main

import (
	"fmt"
	"os"
	"rlxos/internal/color"

	"github.com/itsmanjeet/framework/command"
)

func main() {
	if err := command.New("layers").
		About("Manage OS Extension Layers").
		Sub(command.New("list").
			About("Print list of layers").
			Handler(func(self *command.Command, args []string, iface interface{}) error {
				layers, _, _, err := List()
				if err != nil {
					return err
				}

				for _, layer := range layers {
					status := "INACTIVE"
					if layer.Active {
						status = "ACTIVE"
					}
					if layer.Disabled {
						status = "DISABLED"
					}

					fmt.Printf("[%s]\t%s\n", status, layer.Id)
				}
				return nil
			})).
		Sub(command.New("refresh").
			About("Refresh layers mount").
			Handler(func(self *command.Command, args []string, iface interface{}) error {
				return Refresh()
			})).
		Run(os.Args); err != nil {
		color.Error("%v", err)
		os.Exit(1)
	}
}
