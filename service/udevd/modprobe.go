package main

import (
	"fmt"
	"log"
	"path/filepath"
	"strings"
	"syscall"

	"rlxos.dev/pkg/kernel/module"
)

var (
	cache             []module.Info
	kernelModulesPath string
)

func init() {
	var err error

	kernelModulesPath = filepath.Join(SEARCH_PATH, getKernelVersion())
	cache, err = module.LoadCache(kernelModulesPath)
	if err != nil {
		log.Println("failed to read kernel modules cache", kernelModulesPath, err)
	}
}

func LoadKernelModule(alias string) error {
	loaded := map[string]bool{}
	for _, i := range cache {
		if match(i.Aliases, alias) {
			return module.Load(i.Path, kernelModulesPath, loaded)
		}
	}
	return fmt.Errorf("no module found")
}

func getKernelVersion() string {
	var uname syscall.Utsname
	_ = syscall.Uname(&uname)

	var sb strings.Builder
	for _, c := range uname.Release {
		if c == 0 {
			return sb.String()
		}
		sb.WriteByte(byte(c))
	}
	return sb.String()
}

func match(aliases []string, alias string) bool {
	for _, a := range aliases {
		if ok, _ := filepath.Match(a, alias); ok {
			return true
		}
	}
	return false
}
