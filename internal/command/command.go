package command

import (
	"fmt"
)

type Handler func(*Command, []string, interface{}) error

type InitMethod func() (interface{}, error)

type Command struct {
	Id        string
	About     string
	ShortName string
	Usage     string

	Handler Handler

	Flags       []*Flag
	InitMethod  InitMethod
	SubCommands []*Command

	selfPath string
}

func (c *Command) handleFlag(args []string) (int, error) {
	for _, i := range c.Flags {
		if "-"+i.Id == args[0] {
			if i.Count > len(args[1:]) {
				return 0, fmt.Errorf("%s expect %d arguments but %d provided", i.Id, i.Count, len(args[1:]))
			}
			if err := i.Handler(args[1 : i.Count+1]); err != nil {
				return 0, err
			}
			return i.Count, nil
		}
	}
	return 0, fmt.Errorf("invalid flag %s", args[0])
}

func (c *Command) Handle(args []string, iface interface{}) error {
	return c.Handler(c, args, iface)
}
