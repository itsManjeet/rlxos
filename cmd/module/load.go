package main

import (
	"fmt"

	"rlxos.dev/pkg/kernel/module"
)

func load(args []string) error {
	if len(args) != 1 {
		return fmt.Errorf("no module provided")
	}
	return module.Load(args[0], modulesPath, map[string]bool{})
}
