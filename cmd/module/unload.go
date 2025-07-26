package main

import (
	"fmt"

	"rlxos.dev/pkg/kernel/module"
)

func unload(args []string) error {
	if len(args) != 1 {
		return fmt.Errorf("no module provided")
	}
	return module.Delete(args[0], 0)
}
