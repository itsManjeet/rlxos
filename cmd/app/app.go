package main

import (
	"fmt"
	"log"
	"os"
	"path"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/appimage"
	"rlxos/pkg/color"
)

var (
	ROOT_PATH string
)

func main() {
	ROOT_PATH = path.Join(os.Getenv("HOME"), ".local")

	if err := app.New("app").
		About("AppImage manager").
		Usage("<TASK> <ARGS...> <FLAGS>").
		Flag(flag.New("root").
			About("Set root filesystem for Appimage integration").
			Handler(func(s []string) error {
				ROOT_PATH = "/"
				return nil
			})).
		Flag(flag.New("install-path").
			About("Set custom instalation path for Appimage integration").
			Count(1).
			Handler(func(s []string) error {
				ROOT_PATH = s[0]
				return nil
			})).
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
					if err := appImage.Integrate(ROOT_PATH); err != nil {
						return fmt.Errorf("failed to integrate %s, %v", file, err)
					}
				}
				return nil
			})).
		Run(os.Args); err != nil {

		log.Println(err)
		os.Exit(1)
	}
}
