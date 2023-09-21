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
			if CONFIG_FILE == "" {
				CONFIG_FILE = "/etc/swupd.yml"
			}
			s, err := sysroot.Init(CONFIG_FILE)
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
				fmt.Printf("AVAILABLE   :\n")
				for _, i := range s.Images {
					fmt.Printf(" - %d\n", i)
				}

				updateInfo, err := s.Check()
				if err != nil {
					log.Printf("failed to get remote version %v\n", err)
				}
				fmt.Printf("REMOTE      : %d\n", updateInfo.Version)
				if updateInfo.Version != s.Images[0] {
					fmt.Printf("UPDATED AVAILABLE %d\n%s\n", updateInfo.Version, updateInfo.Changelog)
				} else {
					fmt.Println("SYSTEM IS UPTO DATE")
				}

				return nil
			})).
		Sub(app.New("update").
			About("Download and apply system updates").
			Handler(func(c *app.Command, args []string, i interface{}) error {
				s := i.(*sysroot.Sysroot)
				updateInfo, err := s.Check()
				if err != nil {
					log.Printf("failed to get remote version %v\n", err)
				}

				if updateInfo.Version == s.Images[0] {
					log.Println("SYSTEM IS ALREADY UPTO DATE", updateInfo.Version)
				}

				log.Printf("Applying system updates %d -> %d\n", s.Images[0], updateInfo.Version)
				if err := s.Update(updateInfo); err != nil {
					return err
				}

				return nil
			}))
}
