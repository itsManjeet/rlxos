package main

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/element"
	"rlxos/internal/element/builder"
	"rlxos/pkg/cmd"
	"rlxos/pkg/cmd/flag"
)

var (
	projectPath string
	cachePath   string
)

func main() {
	projectPath, _ = os.Getwd()
	if err := cmd.New("builder").
		About("rlxos os build repository").
		Usage("<TASK> <FLAGS?> <ARGS...>").
		Flag(flag.New("path").
			Count(1).
			About("Specify project path").
			Handler(func(s []string) error {
				projectPath = s[0]
				return nil
			})).
		Flag(flag.New("cache-path").
			Count(1).
			About("Specify cache path").
			Handler(func(s []string) error {
				cachePath = s[0]
				return nil
			})).
		Handler(func(c *cmd.Command, args []string) error {
			return c.Help()
		}).
		Sub(cmd.New("build").
			About("build element").
			Handler(func(c *cmd.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				return b.Build(s[0])
			})).
		Sub(cmd.New("file").
			About("Get path of build cache").
			Handler(func(c *cmd.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				el := b.Get(s[0])
				if el == nil {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := b.CacheFile(el)
				if err != nil {
					return err
				}
				fmt.Println(cachefile)

				return nil
			})).
		Sub(cmd.New("list-files").
			About("List files of build cache").
			Handler(func(c *cmd.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				el := b.Get(s[0])
				if el == nil {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := b.CacheFile(el)
				if err != nil {
					return err
				}

				data, err := exec.Command("tar", "-taf", cachefile).CombinedOutput()
				if err != nil {
					return fmt.Errorf("%s, %v", string(data), err)
				}
				fmt.Println(string(data))

				return nil
			})).
		Sub(cmd.New("status").
			About("List status of caches").
			Handler(func(c *cmd.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				pairs, err := b.List(element.DependencyAll, s[0])
				if err != nil {
					return err
				}

				for _, p := range pairs {
					fmt.Printf("[%s]    %s\n", p.State, p.Path)
				}

				return nil
			})).
		Run(os.Args); err != nil {
		fmt.Printf("ERROR: %v\n", err)
		os.Exit(1)
	}
}

func getBuilder() (*builder.Builder, error) {
	if len(cachePath) == 0 {
		cachePath = path.Join(projectPath, "build")
	}
	return builder.New(projectPath, cachePath)
}

func checkArgs(args []string, count int) error {
	if len(args) != count {
		return fmt.Errorf("expecting %d but got %d arguments", count, len(args))
	}
	return nil
}
