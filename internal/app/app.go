package app

import (
	"fmt"
	"rlxos/internal/app/flag"
)

type Handler func(*Command, []string, interface{}) error

type InitMethod func() (interface{}, error)

type Command struct {
	id        string
	about     string
	shortName string
	usage     string
	selfPath  string
	handler   Handler

	flags       []*flag.Flag
	initMethod  InitMethod
	subCommands []*Command
}

func New(id string) *Command {
	return &Command{
		id:         id,
		initMethod: nil,
	}
}

func (c *Command) ShortName(shortName string) *Command {
	c.shortName = shortName
	return c
}

func (c *Command) About(about string) *Command {
	c.about = about
	return c
}

func (c *Command) Usage(usage string) *Command {
	c.usage = usage
	return c
}

func (c *Command) Handler(handler Handler) *Command {
	c.handler = handler
	return c
}

func (c *Command) Sub(sub *Command) *Command {
	c.subCommands = append(c.subCommands, sub)
	return c
}

func (c *Command) Flag(f *flag.Flag) *Command {
	c.flags = append(c.flags, f)
	return c
}

func (c *Command) Init(i InitMethod) *Command {
	c.initMethod = i
	return c
}

func (c *Command) Help() error {
	fmt.Printf("%s: %s\n", c.selfPath, c.usage)
	fmt.Println(c.about)
	fmt.Printf("TASK:\n")
	for _, s := range c.subCommands {
		fmt.Printf("  %s%*.s %s\n", s.id, 20-len(s.id), " ", s.about)
	}
	fmt.Printf("\nFLAGS:\n")
	for _, f := range c.flags {
		fmt.Printf("  -%s%*.s%s\n", f.GetId(), 20-len(f.GetId()), " ", f.GetAbout())
	}
	return nil
}

func (c *Command) handleFlag(args []string) (int, error) {
	for _, i := range c.flags {
		if "-"+i.GetId() == args[0] {
			if i.GetCount() > len(args[1:]) {
				return 0, fmt.Errorf("%s expect %d arguments but %d provided", i.GetId(), i.GetCount(), len(args[1:]))
			}
			if err := i.GetHandler()(args[1 : i.GetCount()+1]); err != nil {
				return 0, err
			}
			return i.GetCount(), nil
		}
	}
	return 0, fmt.Errorf("invalid flag %s", args[0])
}

func (c *Command) GetCommand(self string, args []string) (*Command, []string, interface{}, error) {
	c.selfPath = self
	if len(args) == 0 && c.handler == nil {
		return nil, nil, nil, nil
	}

	var requiredArgs []string

	var cmd = c
	var foundTask = false
	for i := 0; i < len(args); i++ {
		arg := args[i]
		if arg[0] == '-' {
			count, err := cmd.handleFlag(args[i:])
			if err != nil {
				return nil, nil, nil, err
			}
			i = i + count
			continue
		}

		if !foundTask {
			for _, s := range c.subCommands {
				if arg == s.id || arg == s.shortName {
					cmd = s
					foundTask = true
					break
				}
			}
			if foundTask {
				continue
			}
		}
		requiredArgs = append(requiredArgs, arg)
	}
	var result interface{}
	if cmd.initMethod != nil {
		var err error
		result, err = cmd.initMethod()
		if err != nil {
			return nil, nil, nil, err
		}
	}
	if result == nil && c.initMethod != nil {
		var err error
		result, err = c.initMethod()
		if err != nil {
			return nil, nil, nil, err
		}
	}
	return cmd, requiredArgs, result, nil
}

func (c *Command) Handle(args []string, iface interface{}) error {
	return c.handler(c, args, iface)
}

func (c *Command) Run(args []string) error {
	cmd, args, result, err := c.GetCommand(args[0], args[1:])
	if err != nil {
		return err
	}

	if cmd == nil {
		return c.Help()
	}
	return cmd.Handle(args, result)
}
