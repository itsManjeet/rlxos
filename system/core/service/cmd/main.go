package main

import (
	"flag"
	"fmt"
	"os"
)

var (
	commands = map[string]func([]string) error{
		"startup": startup,
	}
)

func init() {

}

func main() {
	flag.Parse()

	if len(flag.Args()) == 0 {
		flag.Usage()
		return
	}

	cmd, ok := commands[flag.Args()[0]]
	if !ok {
		fmt.Println("Invalid command", flag.Args()[0])
		flag.Usage()
		os.Exit(1)
	}

	if err := cmd(flag.Args()[1:]); err != nil {
		fmt.Println("ERROR", err)
		os.Exit(1)
	}
}
