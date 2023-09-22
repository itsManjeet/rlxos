package main

import (
	"fmt"
	"os"
	"path"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/appimage"
	"rlxos/pkg/color"
)

func appimageCommand() *app.Command {
	APPIMAGE_ROOT_PATH := path.Join(os.Getenv("HOME"), ".local")
	return app.New("app").
		About("AppImage manager").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Flag(flag.New("root").
			About("Set root filesystem for Appimage integration").
			Handler(func(s []string) error {
				APPIMAGE_ROOT_PATH = "/"
				return nil
			})).
		Flag(flag.New("install-path").
			About("Set custom instalation path for Appimage integration").
			Count(1).
			Handler(func(s []string) error {
				APPIMAGE_ROOT_PATH = s[0]
				return nil
			})).
		Handler(func(c *app.Command, args []string, i interface{}) error {
			cmd, args, iface, err := c.GetCommand("app", args)
			if err != nil {
				return err
			}
			if cmd == nil || cmd == c {
				return c.Help()
			}
			return cmd.Handle(args, iface)
		}).
		Sub(app.New("integrate").
			About("Integrate AppImage into system").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) == 0 {
					return fmt.Errorf("no appimage file provided")
				}

				for _, file := range s {
					appImage, err := appimage.Load(file)
					if err != nil {
						return fmt.Errorf("failed to load %s, %v", file, err)
					}

					color.Process("Integrating %s", file)
					if err := appImage.Integrate(APPIMAGE_ROOT_PATH); err != nil {
						return fmt.Errorf("failed to integrate %s, %v", file, err)
					}
				}
				return nil
			}))
}
