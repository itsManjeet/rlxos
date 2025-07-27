package ensure

import (
	"log"
	"os"
	"os/exec"
)

func Output[T comparable](actual, expected T, format string, args ...interface{}) {
	if actual != expected {
		log.Fatalf(format, args...)
	}
}

func Foreach[T any](l []T, f func(l T) error) error {
	for _, v := range l {
		if err := f(v); err != nil {
			return err
		}
	}
	return nil
}

func Success(err error, format string, args ...interface{}) {
	if err != nil {
		args = append(args, err)
		log.Fatalf(format+": %v", args...)
	}
}

func Target(t string, f func() error, depends ...string) error {
	if _, err := os.Stat(t); err == nil {
		// TODO: check for timestamp of depends if newer that t target
		return nil
	}

	log.Println("TARGET:", t)
	return f()
}

func Cmd(bin string, args ...string) func() error {
	return func() error {
		cmd := exec.Command(bin, args...)
		cmd.Stdout = os.Stdout
		cmd.Stdin = os.Stdin
		cmd.Stderr = os.Stderr
		log.Println("COMMAND:", cmd.Args)
		return cmd.Run()
	}
}
