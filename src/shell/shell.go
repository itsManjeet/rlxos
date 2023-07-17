package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)

	for {
		fmt.Print("> ")
		cmdline, err := reader.ReadString('\n')
		if err != nil {
			log.Fatal(err)
		}

		args := strings.Fields(strings.TrimSuffix(cmdline, "\n"))
		if err := execute(args...); err != nil {
			fmt.Fprintln(os.Stderr, err)
		}
	}
}

func execute(args ...string) error {
	switch args[0] {
	case "exit":
		os.Exit(0)
	case "cd":
		if len(args) != 2 {
			return fmt.Errorf("invalid cd arguments")
		}
		return os.Chdir(args[1])
	default:
		cmd := exec.Command(args[0], args[1:]...)
		cmd.Stderr = os.Stderr
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin

		return cmd.Run()
	}

	return nil

}
