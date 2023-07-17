package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"strings"
	"syscall"
)

type Layer struct {
	Id   string
	Path string

	Active bool
}

var (
	searchPath = []string{path.Join("var", "lib", "layers")}
	rootDir    = "/"
	layers     = []Layer{}
)

func main() {
	if err := app.New("layers").
		About("Add and/or remove package layers over rootfilesystem").
		Usage("<TASK> <FLAGS?> <ARGS...>").
		Flag(flag.New("search-path").
			Count(1).
			About("Append layers search path").
			Handler(func(s []string) error {
				searchPath = append(searchPath, s...)
				return nil
			})).
		Flag(flag.New("root-dir").
			Count(1).
			About("Specify root directory").
			Handler(func(s []string) error {
				rootDir = s[0]
				return nil
			})).
		Handler(func(c *app.Command, s []string) error {
			return c.Help()
		}).
		Sub(app.New("list").
			About("List All available layers").
			Handler(func(c *app.Command, args []string) error {
				mountedLayers, _, err := parseMountData()
				if err != nil {
					return err
				}
				updateLayersList()
				resLayers := layers
				for i, l := range resLayers {
					if contains(mountedLayers, path.Join(rootDir, l.Path)) {
						resLayers[i].Active = true
					}
				}
				if err != nil {
					return fmt.Errorf("failed to list layers, %v", err)
				}

				if len(layers) == 0 {
					return fmt.Errorf("no layers found in any search paths %v", searchPath)
				}

				for _, l := range layers {
					state := "ACTIVE  "
					if !l.Active {
						state = "INACTIVE"
					}
					fmt.Printf("%s %s\n", state, l.Id)
				}
				return nil
			})).
		Sub(app.New("refresh").
			About("Refresh the layers").
			Handler(func(c *app.Command, args []string) error {
				var flag uintptr = 0
				isMounted, err := checkIsMounted()
				if err != nil {
					return err
				}
				if isMounted {
					flag = syscall.MS_REMOUNT | syscall.MS_RDONLY
				}
				lower := path.Join(rootDir, "usr")
				for _, l := range layers {
					log.Printf("enabling layer %s\n", l.Id)
					lower += ":" + path.Join(rootDir, l.Path)
				}
				log.Println("LOWERDIR", lower)
				if err := syscall.Mount("overlay", path.Join(rootDir, "usr"), "overlay", flag, "lowerdir="+lower); err != nil {
					return err
				}

				return nil
			})).
		Run(os.Args); err != nil {

		fmt.Printf("ERROR: %v\n", err)
		os.Exit(1)
	}
}

func checkIsMounted() (bool, error) {
	_, isMounter, err := parseMountData()
	return isMounter, err
}

func parseMountData() ([]string, bool, error) {
	data, err := exec.Command("mount").CombinedOutput()
	if err != nil {
		return nil, false, fmt.Errorf("failed to read mount data %v", err)
	}

	for _, m := range strings.Split(string(data), "\n") {
		if strings.HasPrefix(m, "overlay on /usr type overlay") {
			parameters := strings.Split(strings.TrimPrefix(strings.TrimSuffix(strings.Trim(strings.TrimPrefix(m, "overlay on /usr type overlay"), " "), ")"), "("), ",")
			for _, p := range parameters {
				if strings.HasPrefix(p, "lowerdir=") {
					layers := strings.Split(strings.TrimPrefix(p, "lowerdir="), ":")
					layers = layers[1:] // skip /usr
					return layers, true, nil
				}
			}
		}
	}
	return nil, false, nil
}

func updateLayersList() {
	layers = []Layer{}
	for _, i := range searchPath {
		dir, err := ioutil.ReadDir(path.Join(rootDir, i))
		if err != nil {
			log.Printf("failed to read %s, %v", i, err)
			continue
		}

		for _, l := range dir {
			if l.IsDir() {
				layers = append(layers, Layer{
					Id:     l.Name(),
					Path:   path.Join(i, l.Name()),
					Active: false,
				})
			}
		}
	}
}

func contains(lst []string, v string) bool {
	for _, i := range lst {
		if i == v {
			return true
		}
	}
	return false
}
