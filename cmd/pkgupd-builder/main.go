package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"rlxos/internal/element"
	"rlxos/internal/element/builder"
)

func printHelp() {
	fmt.Println(os.Args[0], " - rlxos build utility")
}

func checkArgs(args []string, size int) {
	if len(args) != size {
		fmt.Printf("ERROR: expected '%d' but got '%d'\n", size, len(args))
		os.Exit(1)
	}
}

func build(b *builder.Builder, id string) {
	if err := b.Build(id); err != nil {
		log.Fatal(err)
	}
}

func status(b *builder.Builder, id string) {
	pairs, err := b.List(element.DependencyAll, id)
	if err != nil {
		log.Fatal(err)
	}

	for _, pair := range pairs {
		fmt.Println("    ["+pair.State.String()+"] ", pair.Path)
	}
}

func listfiles(b *builder.Builder, id string) {
	e := b.Get(id)
	if e == nil {
		log.Fatal("ERROR: no element found ", id)

	}
	cachefile, err := b.CacheFile(e)
	if err != nil {
		log.Fatal("ERROR: failed to get cache file ", err)
	}

	data, err := exec.Command("tar", "-taf", cachefile).CombinedOutput()
	if err != nil {
		log.Fatal("ERROR: failed to read cache file ", cachefile, string(data), err)
	}
	fmt.Println(string(data))
}

func main() {
	projectPath, _ := os.Getwd()
	var task string
	var args []string
	for i := 1; i < len(os.Args); i++ {
		arg := os.Args[i]
		if arg[0] == '-' {
			switch arg {
			case "-project-path":
				i = i + 1
				projectPath = os.Args[i]
			default:
				fmt.Println("ERROR: invalid flag", arg)
			}
		} else if len(task) == 0 {
			task = arg
		} else {
			args = append(args, arg)
		}
	}

	b, err := builder.New(projectPath)
	if err != nil {
		log.Panicln(err)
	}

	if len(task) == 0 {
		printHelp()
		os.Exit(0)
	}

	switch task {
	case "build":
		checkArgs(args, 1)
		build(b, args[0])
	case "status":
		checkArgs(args, 1)
		status(b, args[0])
	case "list-files":
		checkArgs(args, 1)
		listfiles(b, args[0])
	}
}
