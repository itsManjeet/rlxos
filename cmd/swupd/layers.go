package main

import (
	"fmt"
	"path"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/layers"
)

func layersCommand() *app.Command {
	searchDir := []string{path.Join("var", "lib", "layers")}
	rootDir := "/"
	serverUrl := "http://storage.rlxos.dev/"

	return app.New("layers").
		About("Add and/or remove package layers over rootfilesystem").
		Usage("<TASK> <FLAGS?> <ARGS...>").
		Init(func() (interface{}, error) {
			m := &layers.Manager{
				RootDir:    rootDir,
				SearchPath: searchDir,
				ServerUrl:  serverUrl,
			}
			return m, nil
		}).
		Flag(flag.New("search-path").
			Count(1).
			About("Append layers search path").
			Handler(func(s []string) error {
				searchDir = append(searchDir, s[0])
				return nil
			})).
		Flag(flag.New("root").
			Count(1).
			About("set root directory").
			Handler(func(s []string) error {
				rootDir = s[0]
				return nil
			})).
		Flag(flag.New("server").
			Count(1).
			About("set server url").
			Handler(func(s []string) error {
				serverUrl = s[0]
				return nil
			})).
		Handler(func(c *app.Command, args []string, i interface{}) error {
			cmd, args, iface, err := c.GetCommand("layers", args)
			if err != nil {
				return err
			}
			if cmd == nil || cmd == c {
				return c.Help()
			}
			return cmd.Handle(args, iface)
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
				return m.Refresh(false)
			})).
		Sub(app.New("deactivate").
			About("Deactivate all the layers").
			Handler(func(c *app.Command, args []string, b interface{}) error {
				m := b.(*layers.Manager)
				return m.Refresh(true)
			})).
		Sub(app.New("add").
			About("Add New Layer").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) < 1 {
					return fmt.Errorf("no layer name provided")
				}
				manager := i.(*layers.Manager)
				layerid := ""
				if len(s) == 2 {
					layerid = s[1]
				}
				return manager.Add(s[0], layerid)
			})).
		Sub(app.New("remove").
			About("Remove Layer").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) != 1 {
					return fmt.Errorf("no layer name provided")
				}
				manager := i.(*layers.Manager)
				return manager.Remove(s[0])
			}))
}
