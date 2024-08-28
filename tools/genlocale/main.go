package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"rlxos/pkg/localize"
	"strings"
)

var (
	path string
)

func init() {
	curdir, _ := os.Getwd()
	flag.StringVar(&path, "path", curdir, "path to locale")
}

func main() {
	flag.Parse()

	if len(flag.Args()) == 0 {
		fmt.Println("usage: genlocale -path <path> <locale>")
		flag.Usage()
		os.Exit(1)
	}
	locale, err := localize.Open(flag.Args()[0])
	if err != nil {
		log.Fatal(err)
	}

	localePath := filepath.Join(path, "locale")

	re := regexp.MustCompile(`T\("([^"]*)"\)`)

	if err := filepath.Walk(path, func(p string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() || filepath.Ext(p) != ".go" || strings.Contains(p, localePath) {
			return nil
		}

		data, err := os.ReadFile(p)
		if err != nil {
			return err
		}

		matches := re.FindAllStringSubmatch(string(data), -1)
		for _, match := range matches {
			if len(match) > 1 {
				if _, ok := locale[match[1]]; !ok {
					locale[match[1]] = match[1]
				}

			}
		}

		return nil
	}); err != nil {
		log.Fatal(err)
	}

	if err := localize.Save(flag.Args()[0], locale); err != nil {
		log.Fatal(err)
	}
}
