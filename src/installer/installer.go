package main

import (
	"fmt"
	"log"
	"os"
	"rlxos/pkg/app"
	"rlxos/src/installer/backend"
)

func main() {

	if err := app.New("installer").
		About("rlxos system installer").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Init(func() (interface{}, error) {
			back, err := backend.New()
			if err != nil {
				return nil, fmt.Errorf("failed to create installer backend %v", err)
			}
			return back, nil
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
				back := i.(*backend.Backend)

				if err := back.Install(s[0]); err != nil {
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
