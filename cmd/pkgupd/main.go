package main

import (
	"os"
	"rlxos/internal/color"
	"rlxos/internal/command"
	"rlxos/internal/pkgupd"
)

func main() {
	var cmd = command.Command{
		Id:    "pkgupd",
		About: "Package Management and Updater tool",
		Usage: "<TASK> <FLAGS?> <ARGS...>",
		InitMethod: func() (interface{}, error) {
			return pkgupd.New()
		},

		SubCommands: []*command.Command{
			{
				Id:    "sync",
				About: "Sync metadata from server",
				Handler: func(c *command.Command, s []string, i interface{}) error {
					pk := i.(*pkgupd.Pkgupd)
					color.Process("SYNCING METADATA %s", pk.Server)
					return pk.Sync(false)
				},
			},
		},
	}

	if err := cmd.Run(os.Args); err != nil {
		color.Error("%v", err)
		os.Exit(1)
	}
}
