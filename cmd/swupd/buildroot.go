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
	projectPath  string
	cachePath    string
	configfile   string
	cleanGarbage bool = false
)

func buildrootCommand() *app.Command {
	projectPath, _ = os.Getwd()
	return app.New("buildroot").
		About("rlxos os build repository").
		Usage("<TASK> <FLAGS?> <ARGS...>").
		Init(func() (interface{}, error) {
			if len(cachePath) == 0 {
				cachePath = path.Join(projectPath, "build")
			}
			return builder.New(projectPath, cachePath)
		}).
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
		Handler(func(c *app.Command, args []string, i interface{}) error {
			cmd, args, iface, err := c.GetCommand("buildroot", args)
			if err != nil {
				return err
			}
			if cmd == nil || cmd == c {
				return c.Help()
			}
			return cmd.Handle(args, iface)
		}).
		Sub(app.New("build").
			About("build element").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				bldr := i.(*builder.Builder)
				return bldr.Build(s[0])
			})).
		Sub(app.New("file").
			About("Get path of build cache").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				bldr := i.(*builder.Builder)
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
		Sub(app.New("list-files").
			About("List files of build cache").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				bldr := i.(*builder.Builder)

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
		Sub(app.New("show").
			About("Show build configuration for element").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				bldr := i.(*builder.Builder)

				el, ok := bldr.Get(s[0])
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
				bldr := i.(*builder.Builder)

				el, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing element %s", s[0])
				}
				cachefile, err := bldr.CacheFile(el)
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

				cached := 0

				for _, cf := range cachedir {
					if isGarbage(cf.Name()) {
						garbageElements = append(garbageElements, cf.Name())
					}
					if stat, err := os.Stat(path.Join(bldr.CachePath(), cf.Name())); err == nil {
						cached++
						totalSize += stat.Size()
					}
				}

				fmt.Printf("\n----------------------------------------\n")
				fmt.Printf("  %sTOTAL ELEMENTS%s   :  %s%d%s\n", color.Bold, color.Reset, color.Green, totalElements, color.Reset)
				fmt.Printf("  %sCACHED ELEMENTS%s  :  %s%d%s\n", color.Bold, color.Reset, color.Green, cached, color.Reset)
				fmt.Printf("  %sMII ELEMENTS%s     :  %s%d%s\n", color.Bold, color.Reset, color.Green, mmiElements, color.Reset)
				fmt.Printf("  %sMII PERCENTGE%s    :  %s%.2f%%%s\n", color.Bold, color.Reset, color.Green, (float64(mmiElements)/float64(totalElements))*100, color.Reset)
				fmt.Printf("  %sCACHED SIZE%s      :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, (float64(cachedSize) / (1024 * 1024 * 1024)), color.Reset)
				fmt.Printf("  %sTOTAL SIZE%s       :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, (float64(totalSize) / (1024 * 1024 * 1024)), color.Reset)
				fmt.Printf("  %sGARBAGE SIZE%s     :  %s%.2f GiB%s\n", color.Bold, color.Reset, color.Green, ((float64(totalSize) - float64(cachedSize)) / (1024 * 1024 * 1024)), color.Reset)
				fmt.Printf("  %sGARBAGE COUNT%s    :  %s%d%s\n", color.Bold, color.Reset, color.Green, len(garbageElements), color.Reset)
				fmt.Printf("----------------------------------------\n")

				if cleanGarbage {
					for _, g := range garbageElements {
						color.Process("cleaning %s", g)
						os.Remove(path.Join(bldr.CachePath(), g))
					}
				}

				return nil
			})).
		Sub(app.New("dump-metadata").
			About("Dump metadata Database").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if len(s) == 0 {
					return fmt.Errorf("no output path specified")
				}

				bldr := i.(*builder.Builder)

				outputPath := s[0]
				iconsPath := path.Join(outputPath, "icons")
				appsPath := path.Join(outputPath, "apps")
				jsonPath := path.Join(outputPath, "origin")

				for _, dir := range []string{iconsPath, appsPath} {
					os.MkdirAll(dir, 0755)
				}

				metadata := []element.Metadata{}

				for elid, el := range bldr.Pool() {
					color.Process("Adding %s", elid)
					cachefile, _ := bldr.CacheFile(el)
					if _, err := os.Stat(cachefile); os.IsNotExist(err) {
						color.Error("%s not yet cached %s", elid, cachefile)
						continue
					}
					iconfile := "package.svg"
					elementType := element.ElementTypeComponent
					if strings.HasPrefix(elid, "apps/") {
						elementType = element.ElementTypeApp
						if data, err := exec.Command("tar", "-xf", cachefile, "-C", appsPath).CombinedOutput(); err != nil {
							color.Error("failed to extract %s: %s, %v", elid, string(data), err)
							continue
						}

						appfile := path.Join(appsPath, fmt.Sprintf("%s-%s.app", el.Id, el.Version))
						if err := os.Chmod(appfile, 0755); err != nil {
							color.Error("failed to chmod %s, %v", appfile, err)
							continue
						}

						if data, err := exec.Command(appfile, "--appimage-extract", `*.DirIcon`).CombinedOutput(); err != nil {
							color.Error("missing icon file %s: %s, %v", elid, string(data), err)
							continue
						}

						var err error
						iconfile, err = os.Readlink(path.Join("squashfs-root", ".DirIcon"))
						if err != nil {
							color.Error("failed to read .DirIcon link %s: %v", elid, err)
							continue
						}

						if data, err := exec.Command(appfile, "--appimage-extract", iconfile).CombinedOutput(); err != nil {
							color.Error("missing icon file %s: %s, %v", elid, string(data), err)
							continue
						}

						if data, err := exec.Command("mv", path.Join("squashfs-root", iconfile), path.Join(iconsPath, iconfile)).CombinedOutput(); err != nil {
							color.Error("failed to copy icon file %s: %s, %v", elid, string(data), err)
							continue
						}

						os.RemoveAll("squashfs-root")
					} else if strings.HasPrefix(elid, "layers/") {
						elementType = element.ElementTypeLayer
					}

					metadata = append(metadata, element.Metadata{
						Id:      strings.TrimSuffix(elid, ".yml"),
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
		Sub(app.New("status").
			About("List status of caches").
			Handler(func(c *app.Command, s []string, i interface{}) error {
				if err := checkArgs(s, 1); err != nil {
					return err
				}
				bldr := i.(*builder.Builder)

				e, ok := bldr.Get(s[0])
				if !ok {
					return fmt.Errorf("missing %s", s[0])
				}

				tolist := []string{}
				if len(e.Include) > 0 {
					tolist = append(tolist, e.Include...)
				}
				tolist = append(tolist, s[0])

				pairs, err := bldr.List(element.DependencyAll, tolist...)
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
			}))

}
