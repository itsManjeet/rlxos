package command

func (c *Command) GetCommand(self string, args []string) (*Command, []string, interface{}, error) {
	c.selfPath = self
	if len(args) == 0 && c.Handler == nil {
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
				count, err = c.handleFlag(args[i:])
				if err != nil {
					return nil, nil, nil, err
				}

			}
			i = i + count
			continue
		}

		if !foundTask {
			for _, s := range c.SubCommands {
				if arg == s.Id || arg == s.ShortName {
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
	if cmd.InitMethod != nil {
		var err error
		result, err = cmd.InitMethod()
		if err != nil {
			return nil, nil, nil, err
		}
	}
	if result == nil && c.InitMethod != nil {
		var err error
		result, err = c.InitMethod()
		if err != nil {
			return nil, nil, nil, err
		}
	}
	return cmd, requiredArgs, result, nil
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
