package main

import (
	"rlxos.dev/pkg/kernel/module"
)

func cache(args []string) error {
	return module.Cache(searchPath)
}
