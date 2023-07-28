package main

import (
	"fmt"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/element"
	"rlxos/internal/element/builder"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"

	"gopkg.in/yaml.v2"
)

var (
	projectPath string
	cachePath   string
)

func main() {
	projectPath, _ = os.Getwd()
	if err := app.New("builder").
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
		Handler(func(c *app.Command, args []string) error {
			return c.Help()
		}).
		Sub(app.New("build").
			About("build element").
			Handler(func(c *app.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				return b.Build(s[0])
			})).
		Sub(app.New("file").
			About("Get path of build cache").
			Handler(func(c *app.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				el, ok := b.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := b.CacheFile(el)
				if err != nil {
					return err
				}
				fmt.Println(cachefile)

				return nil
			})).
		Sub(app.New("list-files").
			About("List files of build cache").
			Handler(func(c *app.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				el, ok := b.Get(s[0])
				if !ok {
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
		Sub(app.New("show").
			About("Show build configuration for element").
			Handler(func(c *app.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				el, ok := b.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				data, _ := yaml.Marshal(el)
				fmt.Println(string(data))

				return nil
			})).
		Sub(app.New("checkout").
			About("Checkout the cache file").
			Handler(func(c *app.Command, s []string) error {
				if err := checkArgs(s, 2); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				el, ok := b.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := b.CacheFile(el)
				if err != nil {
					return err
				}
				if _, err := os.Stat(cachefile); err != nil {
					return fmt.Errorf("failed to stat %s, %v", cachefile, err)
				}

				checkout_path := s[1]
				if err := os.MkdirAll(checkout_path, 0755); err != nil {
					return fmt.Errorf("failed to create checkout directory %s, %v", checkout_path, err)
				}

				output, err := exec.Command("tar", "-xaf", cachefile, "-C", checkout_path).CombinedOutput()
				if err != nil {
					return fmt.Errorf("failed to checkout %s, %s %v", cachefile, string(output), err)
				}

				fmt.Println(cachefile, "checkout at", checkout_path)

				return nil
			})).
		Sub(app.New("dump").
			About("Dump build cache state").
			Handler(func(c *app.Command, s []string) error {
				_, err := getBuilder()
				if err != nil {
					fmt.Printf(`{"STATUS": false, "ERROR": "%s"}`, err.Error())
					return err
				}
				return nil
			})).
		Sub(app.New("status").
			About("List status of caches").
			Handler(func(c *app.Command, s []string) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				b, err := getBuilder()
				if err != nil {
					return err
				}

				e, ok := b.Get(s[0])
				if !ok {
					return fmt.Errorf("missing %s", s[0])
				}

				tolist := []string{}
				if len(e.Include) > 0 {
					tolist = append(tolist, e.Include...)
				}
				tolist = append(tolist, s[0])

				pairs, err := b.List(element.DependencyAll, tolist...)
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
