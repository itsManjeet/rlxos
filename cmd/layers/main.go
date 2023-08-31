package main

import (
	"fmt"
	"os"
	"path"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/layers"
)

func main() {
	SEARCH_PATH := []string{path.Join("var", "lib", "layers")}
	ROOT_DIR := "/"
	SERVER_URL := "http://storage.rlxos.dev/"

	if err := app.New("layers").
		About("Add and/or remove package layers over rootfilesystem").
		Usage("<TASK> <FLAGS?> <ARGS...>").
		Init(func() (interface{}, error) {
			m := &layers.Manager{
				RootDir:    ROOT_DIR,
				SearchPath: SEARCH_PATH,
				ServerUrl:  SERVER_URL,
				Layers:     []layers.Layer{},
			}
			m.Sync()
			return m, nil
		}).
		Flag(flag.New("search-path").
			Count(1).
			About("Append layers search path").
			Handler(func(s []string) error {
				SEARCH_PATH = append(SEARCH_PATH, s[0])
				return nil
			})).
		Flag(flag.New("root").
			Count(1).
			About("set root directory").
			Handler(func(s []string) error {
				ROOT_DIR = s[0]
				return nil
			})).
		Flag(flag.New("server").
			Count(1).
			About("set server url").
			Handler(func(s []string) error {
				SERVER_URL = s[0]
				return nil
			})).
		Handler(func(c *app.Command, s []string, b interface{}) error {
			return c.Help()
		}).
		Sub(app.New("list").
			About("List All available layers").
			Handler(func(c *app.Command, args []string, b interface{}) error {
				m := b.(*layers.Manager)
				ls, err := m.List()
				if err != nil {
					return err
				}
				if len(ls) == 0 {
					return fmt.Errorf("no layers found in any search paths %v", m.SearchPath)
				}

				for _, l := range ls {
					state := "ACTIVE  "
					if !l.Active {
						state = "INACTIVE"
					}
					fmt.Printf("%s %s\n", state, l.Id)
				}
				return nil
			})).
		Sub(app.New("refresh").
			About("Refresh the layers").
			Handler(func(c *app.Command, args []string, b interface{}) error {
				m := b.(*layers.Manager)
				return m.Refresh()
			})).
		Sub(app.New("create").
			About("Create New Layer").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) < 1 {
					return fmt.Errorf("no layer name provided")
				}
				manager := i.(*layers.Manager)
				return manager.Create(s[0], s[1:])
			})).
		Sub(app.New("remove").
			About("Remove Layer").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) != 1 {
					return fmt.Errorf("no layer name provided")
				}
				manager := i.(*layers.Manager)
				return manager.Remove(s[0])
			})).
		Run(os.Args); err != nil {

		fmt.Printf("ERROR: %v\n", err)
		os.Exit(1)
	}
}
