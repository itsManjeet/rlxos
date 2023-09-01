package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/app"
	"rlxos/pkg/app/flag"
	"rlxos/pkg/color"
	"rlxos/pkg/element"
	"rlxos/pkg/element/builder"
	"strings"

	"gopkg.in/yaml.v2"
)

var (
	projectPath string
	cachePath   string
)

var (
	cleanGarbage bool = false
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
		Flag(flag.New("no-color").
			About("No color on output").
			Handler(func(s []string) error {
				color.NoColor = true
				return nil
			})).
		Flag(flag.New("clean-garbage").
			About("Clean Garbage elements").
			Handler(func(s []string) error {
				cleanGarbage = true
				return nil
			})).
		Init(func() (interface{}, error) {
			if len(cachePath) == 0 {
				cachePath = path.Join(projectPath, "build")
			}
			return builder.New(projectPath, cachePath)
		}).
		Handler(func(c *app.Command, args []string, i interface{}) error {
			return c.Help()
		}).
		Sub(app.New("build").
			About("build element").
			Handler(func(c *app.Command, s []string, i interface{}) error {
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
			Handler(func(c *app.Command, s []string, i interface{}) error {
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
			Handler(func(c *app.Command, s []string, i interface{}) error {
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
			Handler(func(c *app.Command, s []string, i interface{}) error {
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
			Handler(func(c *app.Command, s []string, i interface{}) error {
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
			Handler(func(c *app.Command, s []string, i interface{}) error {
				_, err := getBuilder()
				if err != nil {
					fmt.Printf(`{"STATUS": false, "ERROR": "%s"}`, err.Error())
					return err
				}
				return nil
			})).
		Sub(app.New("check-update").
			About("check and apply update to element").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				bldr := i.(*builder.Builder)
				elements := s
				if len(elements) == 0 {
					for key := range bldr.Pool() {
						if strings.Contains(key, "components/") {
							elements = append(elements, key)
						}

					}
				}

				totalOutDated := 0
				totalUptoDated := 0
				totalFailed := 0

				for _, elid := range elements {
					el, ok := bldr.Get(elid)
					if !ok {
						color.Titled(color.Red, "ERROR", "%s MISSING ELEMENT", elid)
						totalFailed++
						continue
					}
					version, err := bldr.Update(el)
					if err != nil {
						color.Titled(color.Red, "ERROR", "%s API REQUEST FAILED, %v", elid, err)
						totalFailed++
						continue
					}
					if len(version) != 0 {
						color.Titled(color.Cyan, "OUTDATED", "%s %s => %s", elid, el.Version, version)
						totalOutDated++
					} else {
						color.Titled(color.Green, "UPTODATE", "%s %s", elid, el.Version)
						totalUptoDated++
					}
				}

				fmt.Printf("\n----------------------------------------\n")
				fmt.Printf("  %sTOTAL ELEMENTS%s   :  %s%d%s\n", color.Bold, color.Reset, color.Green, len(elements), color.Reset)
				fmt.Printf("  %sTOTAL OUTDATED%s   :  %s%d%s\n", color.Bold, color.Reset, color.Green, totalOutDated, color.Reset)
				fmt.Printf("  %sTOTAL UPTODATED%s  :  %s%d%s\n", color.Bold, color.Reset, color.Green, totalUptoDated, color.Reset)
				fmt.Printf("  %sTOTAL FAILED%s     :  %s%d%s\n", color.Bold, color.Reset, color.Green, totalFailed, color.Reset)
				fmt.Printf("----------------------------------------\n")

				return nil
			})).
		Sub(app.New("metadata").
			About("Generate metdata for cache").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				metadatafile := "metadata.json"
				if len(s) >= 1 {
					metadatafile = s[0]
				}
				builder, err := getBuilder()
				if err != nil {
					fmt.Printf(`{"STATUS": false, "ERROR": "%s"}`, err.Error())
					return err
				}
				allElements := []string{}
				for el := range builder.Pool() {
					allElements = append(allElements, el)
				}
				pairs, err := builder.List(element.DependencyRunTime, allElements...)
				if err != nil {
					return err
				}
				metadata := []element.Metadata{}
				for _, p := range pairs {
					cachefile, _ := builder.CacheFile(p.Value)
					metadata = append(metadata, element.Metadata{
						Id:      p.Path,
						Version: p.Value.Version,
						About:   p.Value.About,
						Depends: p.Value.Depends,
						Cache:   path.Base(cachefile),
					})
				}
				data, err := json.Marshal(metadata)
				if err != nil {
					return err
				}

				return os.WriteFile(metadatafile, data, 0644)
			})).
		Sub(app.New("report").
			About("Report status").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				bldr := i.(*builder.Builder)
				elements := bldr.Pool()
				totalElements := 0
				mmiElements := 0
				var cachedSize int64 = 0
				var totalSize int64 = 0

				cachedElements := []string{}
				garbageElements := []string{}

				for _, el := range elements {
					cachefile, _ := bldr.CacheFile(el)
					cachedElements = append(cachedElements, path.Base(cachefile))
					if stat, err := os.Stat(cachefile); err == nil {
						cachedSize += stat.Size()
					}

					isMII := false
					if len(el.Sources) == 0 {
						isMII = true
					} else {
						for _, u := range el.Sources {
							if strings.Contains(u, "itsmanjeet") {
								isMII = true
								break
							}
						}
					}
					if isMII {
						mmiElements++
					} else {
						totalElements++
					}
				}

				isGarbage := func(e string) bool {
					for _, c := range cachedElements {
						if c == e {
							return false
						}
					}
					return true
				}

				cachedir, err := ioutil.ReadDir(bldr.CachePath())
				if err != nil {
					return fmt.Errorf("failed to read dir %s, %v", bldr.CachePath(), err)
				}

				for _, cf := range cachedir {
					if isGarbage(cf.Name()) {
						garbageElements = append(garbageElements, cf.Name())
					}
					if stat, err := os.Stat(path.Join(bldr.CachePath(), cf.Name())); err == nil {
						totalSize += stat.Size()
					}
				}

				fmt.Printf("\n----------------------------------------\n")
				fmt.Printf("  %sTOTAL ELEMENTS%s   :  %s%d%s\n", color.Bold, color.Reset, color.Green, totalElements, color.Reset)
				fmt.Printf("  %sMII ELEMENTS%s     :  %s%d%s\n", color.Bold, color.Reset, color.Green, mmiElements, color.Reset)
				fmt.Printf("  %sMII PERCENTGE%s    :  %s%.2f%%%s\n", color.Bold, color.Reset, color.Green, (float64(mmiElements)/float64(totalElements))*100, color.Reset)
				fmt.Printf("  %sCACHED SIZE%s      :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, (float64(cachedSize) / (1024 * 1024 * 1024)), color.Reset)
				fmt.Printf("  %sTOTAL SIZE%s       :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, (float64(totalSize) / (1024 * 1024 * 1024)), color.Reset)
				fmt.Printf("  %sGARBAGE SIZE%s     :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, ((float64(totalSize) - float64(cachedSize)) / (1024 * 1024 * 1024)), color.Reset)
				fmt.Printf("  %sGARBAGE COUNT%s    :  %s%d%s\n", color.Bold, color.Reset, color.Green, len(garbageElements), color.Reset)
				fmt.Printf("----------------------------------------\n")

				return nil
			})).
		Sub(app.New("status").
			About("List status of caches").
			Handler(func(c *app.Command, s []string, i interface{}) error {
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
					state := ""
					switch p.State {
					case builder.BuildStatusCached:
						state = color.Green + " CACHED  " + color.Reset
					case builder.BuildStatusWaiting:
						state = color.Magenta + " WAITING " + color.Reset
					}
					fmt.Printf("[%s]    %s\n", state, color.Bold+p.Path+color.Reset)
				}

				return nil
			})).
		Run(os.Args); err != nil {
		color.Error("%v", err)
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
