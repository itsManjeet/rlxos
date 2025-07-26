package main

import (
	"fmt"

	"rlxos.dev/pkg/kernel/module"
)

func info(args []string) error {
	if len(args) != 1 {
		return fmt.Errorf("no module provided")
	}
	p, err := module.Search(args[0], searchPath)
	if err != nil {
		return fmt.Errorf("failed to find kernel module %v %v", args[0], err)
	}

	info, err := module.Parse(p)
	if err != nil {
		return fmt.Errorf("failed to parse kernel module %v %v", p, err)
	}

	fmt.Printf("Name: %v\nAlias: %v\nDepends: %v\n", info.Name, info.Aliases, info.Depends)
	return nil
}
