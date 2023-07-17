package main

import (
	"log"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
)

var (
	CONFIG_FILE = "/etc/config.yml"
)

func main() {

	if err := app.New("swupd").
		About("rlxos software updater tool").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Handler(func(c *app.Command, s []string) error {
			return c.Help()
		}).
		Flag(flag.New("config").
			Count(1).
			About("Specify custom configuration file").
			Handler(func(s []string) error {
				CONFIG_FILE = s[0]
				return nil
			})).
		Run(os.Args); err != nil {

		log.Println(err)
		os.Exit(1)
	}
}
