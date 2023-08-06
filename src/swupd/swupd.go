package main

import (
	"fmt"
	"log"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/src/swupd/backend"
	"rlxos/src/swupd/config"
)

var (
	CONFIG_FILE = "/etc/config.yml"
)

func main() {

	if err := app.New("swupd").
		About("rlxos software updater tool").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Flag(flag.New("config").
			Count(1).
			About("Specify custom configuration file").
			Handler(func(s []string) error {
				CONFIG_FILE = s[0]
				return nil
			})).
		Init(func() (interface{}, error) {
			conf, err := config.Load(CONFIG_FILE)
			if err != nil {
				return nil, err
			}
			return backend.New(conf), nil
		}).
		Handler(func(c *app.Command, s []string, b interface{}) error {
			return c.Help()
		}).
		Sub(app.New("check").
			About("Check software update(s)").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				back := i.(*backend.Backend)
				updateInfo, err := back.Check()
				if err != nil {
					return fmt.Errorf("failed to check updates, %v", err)
				}
				if updateInfo == nil {
					fmt.Println("no update available")
					return nil
				}
				fmt.Printf("New Updates available %d!\n%s\n", updateInfo.Version, updateInfo.Changelog)
				return nil
			})).
		Sub(app.New("update").
			About("Perform software update(s)").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				back := i.(*backend.Backend)
				updateInfo, err := back.Check()
				if err != nil {
					return fmt.Errorf("failed to check updates, %v", err)
				}
				if updateInfo == nil {
					fmt.Println("no update available")
					return nil
				}
				return back.Update(updateInfo)
			})).
		Run(os.Args); err != nil {

		log.Println(err)
		os.Exit(1)
	}
}
