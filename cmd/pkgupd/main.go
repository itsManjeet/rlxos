package main

import (
	"fmt"
	"os"
	"rlxos/internal/color"
	"rlxos/internal/command"
	"rlxos/internal/element"
	"rlxos/internal/pkgupd"
)

const DEFAULT_CONFIG = "/etc/pkgupd.yml"

func main() {
	var root = "/"
	var configfile = DEFAULT_CONFIG

	var cmd = command.Command{
		Id:    "pkgupd",
		About: "Package Management and Updater tool",
		Usage: "<TASK> <FLAGS?> <ARGS...>",
		InitMethod: func() (interface{}, error) {
			if _, err := os.Stat(configfile); err == nil {
				return pkgupd.New(configfile)
			}
			return pkgupd.New()
		},
		Handler: func(c *command.Command, s []string, i interface{}) error {
			return c.Help()
		},

		Flags: []*command.Flag{
			{
				Id:    "root",
				About: "Specify custom roots",
				Count: 1,
				Handler: func(s []string) error {
					root = s[0]
					return nil
				},
			},
			{
				Id:    "config",
				About: "Specify configuration file",
				Count: 1,
				Handler: func(s []string) error {
					configfile = s[0]
					return nil
				},
			},
		},

		SubCommands: []*command.Command{
			{
				Id:    "sync",
				About: "Sync metadata from server",
				Handler: func(c *command.Command, s []string, i interface{}) error {
					pk := i.(*pkgupd.Pkgupd)
					color.Process("SYNCING METADATA %s", pk.Server)
					return pk.Sync(true)
				},
			},
			{
				Id:    "install",
				About: "Install Packages",
				Handler: func(c *command.Command, s []string, i interface{}) error {
					pk := i.(*pkgupd.Pkgupd)

					if err := pk.Sync(false); err != nil {
						return err
					}
					color.Process("Resolving dependencies")
					packages, err := pk.Resolve(s...)
					if err != nil {
						return err
					}

					if len(packages) == 0 {
						fmt.Println("Already installed")
						return nil
					}

					for i, p := range packages {
						fmt.Printf("%d: %s\n", i, p.Id)
					}

					color.Process("Installing packages")
					if err := pk.Install(root, packages); err != nil {
						return err
					}
					return nil
				},
			},
			{
				Id:    "uninstall",
				About: "Uninstall Package",
				Handler: func(c *command.Command, s []string, i interface{}) error {
					pk := i.(*pkgupd.Pkgupd)
					if err := pk.Sync(false); err != nil {
						return err
					}
					elements := []element.Metadata{}
					for _, a := range s {
						el, ok := pk.Get(a)
						if !ok {
							return fmt.Errorf("missing specified package %s", a)
						}
						elements = append(elements, el)
					}
					color.Process("Uninstalling %v", s)
					return pk.Uninstall(root, elements)
				},
			},
			{
				Id:    "search",
				About: "Search package from information",
				Handler: func(c *command.Command, s []string, i interface{}) error {
					if len(s) == 0 {
						return fmt.Errorf("no search information provided")
					}
					pk := i.(*pkgupd.Pkgupd)
					if err := pk.Sync(false); err != nil {
						return err
					}
					found := pk.Search(s[0])
					if len(found) == 0 {
						return fmt.Errorf("no component found with id: '%s'", s[0])
					}

					for i, comp := range found {
						fmt.Printf("%d. %s - %s\n", i+1, comp.Id, comp.About)
					}
					return nil
				},
			},
		},
	}

	if err := cmd.Run(os.Args); err != nil {
		color.Error("%v", err)
		os.Exit(1)
	}
}
