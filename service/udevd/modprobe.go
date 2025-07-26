package main

import (
	"fmt"
	"slices"
	"sync"

	"rlxos.dev/pkg/kernel/module"
)

var (
	cache []module.Info
)

func init() {
	sync.OnceFunc(func() {
		cache, _ = module.LoadCache(SEARCH_PATH)
	})
}

func LoadKernelModule(alias string) error {
	loaded := map[string]bool{}
	for _, i := range cache {
		if slices.Contains(i.Aliases, alias) {
			return module.Load(i.Path, SEARCH_PATH, loaded)
		}
	}
	return fmt.Errorf("no module found")
}
