package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"syscall"
)

var (
	root          string
	kernelVersion string
	modulesPath   string
	commands      = map[string]func([]string) error{
		"load":   load,
		"unload": unload,
		"info":   info,
		"cache":  cache,
	}
)

func init() {
	flag.StringVar(&root, "root", "/", "System root")
	flag.StringVar(&kernelVersion, "kernel", getKernelVersion(), "kernel version")
	flag.Usage = func() {
		fmt.Printf("Usage: %s <OPTION> MODUES...\n", os.Args[0])
		flag.PrintDefaults()
	}
}

func main() {
	flag.Parse()
	modulesPath = filepath.Join(root, "lib/modules", kernelVersion)

	if flag.NArg() == 0 {
		flag.Usage()
		return
	}

	cmd, ok := commands[flag.Arg(0)]
	if !ok {
		fmt.Fprintf(os.Stderr, "invalid command %v", flag.Arg(0))
		os.Exit(1)
	}

	if err := cmd(flag.Args()[1:]); err != nil {
		fmt.Fprintf(os.Stderr, "ERROR: %v", err)
		os.Exit(1)
	}
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
