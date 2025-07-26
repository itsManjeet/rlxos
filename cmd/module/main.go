package main

import (
	"flag"
	"fmt"
	"os"
)

var (
	searchPath string
	commands   = map[string]func([]string) error{
		"load":   load,
		"unload": unload,
		"info":   info,
		"cache":  cache,
	}
)

func init() {
	flag.StringVar(&searchPath, "-search-path", "/lib/modules/", "Modules search path")
	flag.Usage = func() {
		fmt.Printf("Usage: %s <OPTION> MODUES...\n", os.Args[0])
		flag.PrintDefaults()
	}
}

func main() {
	flag.Parse()

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
