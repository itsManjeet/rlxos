/*
 * Copyright (c) 2025 Manjeet Singh <itsmanjeet1998@gmail.com>.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
)

var (
	cachePath string
	sysroot   string
	target    string
	builders  = map[string]Builder{
		"meson": &Meson{},
	}
)

func init() {
	flag.StringVar(&cachePath, "cache-path", os.TempDir(), "Cache Path")
	flag.StringVar(&sysroot, "sysroot", "", "Sysroot")
	flag.StringVar(&target, "target", fmt.Sprintf("%s-linux-musl", runtime.GOARCH), "Target")
}

func main() {
	flag.Parse()

	if flag.NArg() == 0 {
		flag.Usage()
		return
	}

	for _, configPath := range flag.Args() {
		id := strings.TrimSuffix(filepath.Base(configPath), filepath.Ext(configPath))
		data, err := os.ReadFile(configPath)
		if err != nil {
			log.Fatal(err)
		}

		var config Config
		if err := json.Unmarshal(data, &config); err != nil {
			log.Fatal(err)
		}

		sourcePath := filepath.Join(cachePath, id)
		if err := build(config, sourcePath); err != nil {
			log.Fatal(err)
		}
	}
}

func build(c Config, p string) error {
	_ = os.MkdirAll(p, 0755)

	builder, ok := builders[c.Kind]
	if !ok {
		return fmt.Errorf("no builder found with id %v", c.Kind)
	}

	for _, url := range c.Sources {
		log.Println("Downloading ", url)
		if err := exec.Command("wget", "-nc", url, "-P", cachePath).Run(); err != nil {
			return fmt.Errorf("failed to download %v: %v", url, err)
		}

		if err := exec.Command("tar", "-xf", filepath.Join(cachePath, filepath.Base(url)), "-C", p, "--strip-components=1").Run(); err != nil {
			return fmt.Errorf("failed to extract %v: %v", url, err)
		}
	}

	if err := builder.Build(c, p); err != nil {
		return fmt.Errorf("failed to build %v: %v", filepath.Base(p), err)
	}

	return nil
}
