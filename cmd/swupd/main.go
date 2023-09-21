package main

import (
	"fmt"
	"os"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/color"
)

var (
	projectPath string
	cachePath   string
)

var (
	cleanGarbage bool = false
	CONFIG_FILE  string
)

func main() {
	projectPath, _ = os.Getwd()

	if err := app.New("swupd").
		About("Software Management and Deployment Utility").
		Handler(func(c *app.Command, s []string, i interface{}) error {
			return c.Help()
		}).
		Flag(flag.New("path").
			Count(1).
			About("Specify project path").
			Handler(func(s []string) error {
				projectPath = s[0]
				return nil
			})).
		Flag(flag.New("cache-path").
			Count(1).
			About("Specify cache path").
			Handler(func(s []string) error {
				cachePath = s[0]
				return nil
			})).
		Flag(flag.New("config").
			Count(1).
			About("Specify config file").
			Handler(func(s []string) error {
				CONFIG_FILE = s[0]
				return nil
			})).
		Flag(flag.New("no-color").
			About("No color on output").
			Handler(func(s []string) error {
				color.NoColor = true
				return nil
			})).
		Flag(flag.New("clean-garbage").
			About("Clean Garbage elements").
			Handler(func(s []string) error {
				cleanGarbage = true
				return nil
			})).
		Sub(builderCommand()).
		Sub(sysRootCommand()).
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
