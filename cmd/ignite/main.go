package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/internal/color"
	"rlxos/internal/element"
	"rlxos/internal/ignite"
	"strings"

	"github.com/itsmanjeet/framework/command"
	"github.com/itsmanjeet/framework/command/flag"

	"gopkg.in/yaml.v2"
)

var (
	projectPath  string
	cleanGarbage bool = false
)

func main() {
	projectPath, _ = os.Getwd()
	if err := command.New("ignite").
		About("rlxos os build repository").
		Usage("<TASK> <FLAGS?> <ARGS...>").
		Init(func() (interface{}, error) {
			return ignite.New(projectPath)
		}).
		Flag(flag.New("path").
			Count(1).
			About("Specify project path").
			Handler(func(s []string) error {
				projectPath = s[0]
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
		Handler(func(c *command.Command, args []string, i interface{}) error {
			return c.Help()
		}).
		Sub(command.New("build").
			About("build element").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 1); err != nil {
					return err
				}
				bldr := i.(*ignite.Ignite)
				return bldr.Build(s[0])
			})).
		Sub(command.New("info").
			About("Print builder Environment Information").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				bldr := i.(*ignite.Ignite)
				data, _ := yaml.Marshal(bldr)
				fmt.Println(string(data))
				return nil
			})).
		Sub(command.New("pull").
			About("Pull artifact cache of element").
			Handler(func(self *command.Command, args []string, iface interface{}) error {
				if err := checkargs(args, 1); err != nil {
					return err
				}
				ignt := iface.(*ignite.Ignite)
				depends, err := ignt.Resolve(element.DependencyAll, args[0])
				if err != nil {
					return err
				}

				if ignt.ArtifactServer == "" {
					return fmt.Errorf("no artifact server url specified")
				}

				for _, depend := range depends {
					if err := ignt.Pull(depend.Value); err != nil {
						color.Error("failed to fetch %s: %v", depend.Path, err)
						continue
					}
				}
				return nil
			})).
		Sub(command.New("shell").
			About("Create and Enter shell").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 1); err != nil {
					return err
				}
				ignt := i.(*ignite.Ignite)
				elementInfo, ok := ignt.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				container, err := ignt.Setup(ignite.SETUP_TYPE_SHELL, s[0], elementInfo)
				if err != nil {
					return err
				}
				defer container.Delete()

				return container.Shell(nil)
			})).
		Sub(command.New("file").
			About("Get path of build cache").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 1); err != nil {
					return err
				}
				bldr := i.(*ignite.Ignite)
				el, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := bldr.CacheFile(el)
				if err != nil {
					return err
				}
				fmt.Println(cachefile)

				return nil
			})).
		Sub(command.New("list-files").
			About("List files of build cache").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 1); err != nil {
					return err
				}
				bldr := i.(*ignite.Ignite)

				el, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := bldr.CacheFile(el)
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
		Sub(command.New("show").
			About("Show build configuration for element").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 1); err != nil {
					return err
				}
				bldr := i.(*ignite.Ignite)

				el, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				// data, _ := yaml.Marshal(el)
				// fmt.Println(string(data))

				fmt.Print(el)

				return nil
			})).
		Sub(command.New("checkout").
			About("Checkout the cache file").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 2); err != nil {
					return err
				}
				bldr := i.(*ignite.Ignite)

				el, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := bldr.CacheFile(el)
				if err != nil {
					return err
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
		Sub(command.New("check-update").
			About("check and apply update to element").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				bldr := i.(*ignite.Ignite)
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
		Sub(command.New("report").
			About("Report status").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				bldr := i.(*ignite.Ignite)
				elements := bldr.Pool()
				totalElements := 0
				mmiElements := 0
				var cachedSize uint64 = 0
				var totalSize uint64 = 0

				cachedElements := []string{}
				garbageElements := []string{}

				for _, el := range elements {
					cachefile, _ := bldr.CacheFile(el)
					cachedElements = append(cachedElements, path.Base(cachefile))
					if stat, err := os.Stat(cachefile); err == nil {
						cachedSize += uint64(stat.Size())
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

				cachedir, err := os.ReadDir(bldr.ArtifactDir())
				if err != nil {
					return fmt.Errorf("failed to read dir %s, %v", bldr.ArtifactDir(), err)
				}

				cached := 0

				for _, cf := range cachedir {
					if isGarbage(cf.Name()) {
						garbageElements = append(garbageElements, cf.Name())
					}
					if stat, err := os.Stat(path.Join(bldr.ArtifactDir(), cf.Name())); err == nil {
						cached++
						totalSize += uint64(stat.Size())
					}
				}

				fmt.Printf("\n----------------------------------------\n")
				fmt.Printf("  %sTOTAL ELEMENTS%s   :  %s%d%s\n", color.Bold, color.Reset, color.Green, totalElements, color.Reset)
				fmt.Printf("  %sCACHED ELEMENTS%s  :  %s%d%s\n", color.Bold, color.Reset, color.Green, cached, color.Reset)
				fmt.Printf("  %sMII ELEMENTS%s     :  %s%d%s\n", color.Bold, color.Reset, color.Green, mmiElements, color.Reset)
				fmt.Printf("  %sMII PERCENTGE%s    :  %s%.2f%%%s\n", color.Bold, color.Reset, color.Green, (float64(mmiElements)/float64(totalElements))*100, color.Reset)
				fmt.Printf("  %sCACHED SIZE%s      :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, float64(cachedSize)/(1024*1024*1024), color.Reset)
				fmt.Printf("  %sTOTAL SIZE%s       :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, float64(totalSize)/(1024*1024*1024), color.Reset)
				fmt.Printf("  %sGARBAGE SIZE%s     :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, (float64(totalSize)-float64(cachedSize))/(1024*1024*1024), color.Reset)
				fmt.Printf("  %sGARBAGE COUNT%s    :  %s%d%s\n", color.Bold, color.Reset, color.Green, len(garbageElements), color.Reset)
				fmt.Printf("----------------------------------------\n")

				if cleanGarbage {
					for _, g := range garbageElements {
						color.Process("cleaning %s", g)
						err := os.Remove(path.Join(bldr.ArtifactDir(), g))
						if err != nil {
							log.Println(err)
						}
					}
				}

				return nil
			})).
		Sub(command.New("generate-market-data").
			About("Generate Market Data").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if len(s) == 0 {
					return fmt.Errorf("no output path specified")
				}

				bldr := i.(*ignite.Ignite)

				outputPath := s[0]
				iconsPath := path.Join(outputPath, "icons")
				appsPath := path.Join(outputPath, "apps")
				jsonPath := path.Join(outputPath, "origin")

				for _, dir := range []string{iconsPath, appsPath} {
					err := os.MkdirAll(dir, 0755)
					if err != nil {
						return err
					}
				}

				var metadata []element.Metadata

				for elementID, el := range bldr.Pool() {
					color.Process("Adding %s", elementID)
					cachefile, _ := bldr.CacheFile(el)
					if _, err := os.Stat(cachefile); os.IsNotExist(err) {
						color.Error("%s not yet cached %s", elementID, cachefile)
						continue
					}
					iconfile := "package.svg"
					elementType := element.ElementTypeComponent
					if strings.HasPrefix(elementID, "apps/") {
						elementType = element.ElementTypeApp
						if data, err := exec.Command("tar", "-xf", cachefile, "-C", appsPath).CombinedOutput(); err != nil {
							color.Error("failed to extract %s: %s, %v", elementID, string(data), err)
							continue
						}

						appfile := path.Join(appsPath, fmt.Sprintf("%s-%s.app", el.Id, el.Version))
						if err := os.Chmod(appfile, 0755); err != nil {
							color.Error("failed to chmod %s, %v", appfile, err)
							continue
						}

						if data, err := exec.Command(appfile, "--appimage-extract", `*.DirIcon`).CombinedOutput(); err != nil {
							color.Error("missing icon file %s: %s, %v", elementID, string(data), err)
							continue
						}

						var err error
						iconfile, err = os.Readlink(path.Join("squashfs-root", ".DirIcon"))
						if err != nil {
							color.Error("failed to read .DirIcon link %s: %v", elementID, err)
							continue
						}

						if data, err := exec.Command(appfile, "--appimage-extract", iconfile).CombinedOutput(); err != nil {
							color.Error("missing icon file %s: %s, %v", elementID, string(data), err)
							continue
						}

						if data, err := exec.Command("mv", path.Join("squashfs-root", iconfile), path.Join(iconsPath, iconfile)).CombinedOutput(); err != nil {
							color.Error("failed to copy icon file %s: %s, %v", elementID, string(data), err)
							continue
						}

						if err := os.RemoveAll("squashfs-root"); err != nil {
							return err
						}
					} else if strings.HasPrefix(elementID, "layers/") {
						elementType = element.ElementTypeLayer
					}

					metadata = append(metadata, element.Metadata{
						Id:      strings.TrimSuffix(elementID, ".yml"),
						Version: el.Version,
						About:   el.About,
						Icon:    path.Base(iconfile),
						Cache:   path.Base(cachefile),
						Type:    elementType,
					})
				}

				data, err := json.Marshal(metadata)
				if err != nil {
					return fmt.Errorf("invalid json format %v, %v", metadata, err)
				}

				if err := os.WriteFile(jsonPath, data, 0644); err != nil {
					return fmt.Errorf("failed to write json data %v", err)
				}

				color.Process("FINISHED")
				return nil
			})).
		Sub(command.New("status").
			About("List status of caches").
			Handler(func(c *command.Command, s []string, i interface{}) error {
				if err := checkargs(s, 1); err != nil {
					return err
				}
				bldr := i.(*ignite.Ignite)

				e, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing %s", s[0])
				}

				var tolist []string
				if len(e.Include) > 0 {
					tolist = append(tolist, e.Include...)
				}
				tolist = append(tolist, s[0])

				pairs, err := bldr.Resolve(element.DependencyAll, tolist...)
				if err != nil {
					return err
				}

				for _, p := range pairs {
					state := ""
					switch p.State {
					case ignite.BuildStatusCached:
						state = color.Green + " CACHED  " + color.Reset
					case ignite.BuildStatusWaiting:
						state = color.Magenta + " WAITING " + color.Reset
					}
					fmt.Printf("[%s]    %s\n", state, color.Bold+p.Path+color.Reset)
				}

				return nil
			})).Run(os.Args); err != nil {
		color.Error("%v", err)
		os.Exit(1)
	}

}

func checkargs(args []string, count int) error {
	if len(args) != count {
		return fmt.Errorf("expected '%d' arguments but '%d' provided", count, len(args))
	}
	return nil
}
