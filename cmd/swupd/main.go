package main

import (
	"fmt"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/color"
)

func main() {

	if err := app.New("swupd").
		About("Software Management and Deployment Utility").
		Handler(func(c *app.Command, s []string, i interface{}) error {
			return c.Help()
		}).
		Flag(flag.New("config").
			Count(1).
			About("Specify config file").
			Handler(func(s []string) error {
				configfile = s[0]
				return nil
			})).
		Sub(buildrootCommand()).
		Sub(sysRootCommand()).
		Sub(appimageCommand()).
		Sub(osinfoCommand()).
		Sub(layersCommand()).
		Run(os.Args); err != nil {
		color.Error("%v", err)
		os.Exit(1)
	}
}

func checkArgs(args []string, count int) error {
	if len(args) != count {
		return fmt.Errorf("expecting %d but got %d arguments", count, len(args))
	}
	return nil
}
