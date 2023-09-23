package main

import (
	"fmt"
	"log"
	"rlxos/pkg/app"
	"rlxos/pkg/sysroot"
)

func sysRootCommand() *app.Command {
	return app.New("sysroot").
		About("System Roots Management utility").
		Handler(func(c *app.Command, args []string, i interface{}) error {
			cmd, args, iface, err := c.GetCommand("sysroot", args)
			if err != nil {
				return err
			}
			if cmd == nil || cmd == c {
				return c.Help()
			}
			return cmd.Handle(args, iface)
		}).
		Init(func() (interface{}, error) {
			if configfile == "" {
				configfile = "/etc/swupd.yml"
			}
			s, err := sysroot.Init(configfile)
			if err != nil {
				return nil, err
			}
			return s, nil
		}).
		Sub(app.New("status").
			About("Show sysroot status").
			Handler(func(c *app.Command, args []string, i interface{}) error {
				s := i.(*sysroot.Sysroot)

				fmt.Printf("ACTIVE      : %d\n", s.InUse)
				fmt.Printf("AVAILABLE   : %v\n", s.Images)

				remoteImages, err := s.ListRemoteReleases()
				if err != nil {
					log.Printf("failed to get remote version %v\n", err)
				}
				fmt.Printf("REMOTE      : %v\n", remoteImages)
				if s.HasUpdates(remoteImages) {
					changelog, err := s.GetChangelog(remoteImages[0])
					if err != nil {
						return err
					}
					fmt.Printf("UPDATED AVAILABLE %d\n%s\n", remoteImages[0], changelog)
				} else {
					fmt.Println("SYSTEM IS UPTO DATE")
				}

				return nil
			})).
		Sub(app.New("update").
			About("Download and apply system updates").
			Handler(func(c *app.Command, args []string, i interface{}) error {
				s := i.(*sysroot.Sysroot)
				remoteImages, err := s.ListRemoteReleases()
				if err != nil {
					log.Printf("failed to get remote version %v\n", err)
				}
				if s.HasUpdates(remoteImages) {
					changelog, err := s.GetChangelog(remoteImages[0])
					if err != nil {
						return err
					}
					fmt.Printf("UPDATED AVAILABLE %d\n%s\n", remoteImages[0], changelog)
					return s.Update()
				} else {
					fmt.Println("SYSTEM IS UPTO DATE")
				}
				return nil
			}))
}
