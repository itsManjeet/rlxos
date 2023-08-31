package main

import (
	"fmt"
	"log"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/installer"
)

func main() {

	if err := app.New("installer").
		About("rlxos system installer").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Init(func() (interface{}, error) {
			i, err := installer.New(nil)
			if err != nil {
				return nil, fmt.Errorf("failed to create installer backend %v", err)
			}
			return i, nil
		}).
		Handler(func(c *app.Command, s []string, b interface{}) error {
			return c.Help()
		}).
		Sub(app.New("install").
			About("Install system image").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) != 1 {
					return fmt.Errorf("no partition specified")
				}
				installer := i.(*installer.Installer)

				if err := installer.Install(s[0]); err != nil {
					return fmt.Errorf("installation failed, %v", err)
				}
				fmt.Println("Installation successful")
				return nil
			})).
		Run(os.Args); err != nil {

		log.Println(err)
		os.Exit(1)
	}
}
