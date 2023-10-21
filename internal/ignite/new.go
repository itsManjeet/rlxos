package ignite

import (
	"fmt"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"rlxos/internal/color"
	"rlxos/internal/element"
	"strings"
)

func New(projectPath string) (*Ignite, error) {

	bldr := &Ignite{
		Environ:     []string{},
		Variables:   map[string]string{},
		pool:        map[string]*element.Element{},
		projectPath: projectPath,
	}

	for config, forced := range map[string]bool{
		path.Join(os.Getenv("HOME"), ".config", "builder.yml"): false,
		path.Join(projectPath, "config.yml"):                   true,
	} {
		if _, err := os.Stat(config); err != nil {
			if forced {
				return nil, fmt.Errorf("no %s found", config)
			} else {
				continue
			}

		}
		if err := bldr.Import(config); err != nil {
			return nil, err
		}
	}

	for _, importfile := range bldr.Imports {
		if err := bldr.Import(importfile); err != nil {
			return nil, err
		}
	}

	if bldr.CachePath == "" {
		bldr.CachePath = path.Join(projectPath, "build")
	}

	color.Process("Loading elements")
	if err := filepath.WalkDir(path.Join(projectPath, "elements"), func(p string, d fs.DirEntry, err error) error {
		elementType := strings.Split(strings.Trim(strings.TrimPrefix(p, path.Join(projectPath, "elements")), "/"), "/")[0]
		if elementType == "experimental" {
			return nil
		}
		if path.Ext(p) == ".yml" {
			e, err := element.Open(p, bldr.Environ, bldr.Variables)
			if err != nil {
				return fmt.Errorf("failed to load element %s, %v", p, err)
			}
			p = strings.TrimPrefix(p, path.Join(projectPath, "elements")+"/")
			bldr.pool[p] = e
		}
		return nil
	}); err != nil {
		return nil, err
	}

	// create required dirs
	for _, dir := range []string{bldr.SourceDir(), bldr.ArtifactDir(), bldr.TempDir(), bldr.LogDir()} {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return nil, fmt.Errorf("failed to create %s: %v", dir, err)
		}
	}

	return bldr, nil
}

func (bldr *Ignite) Pool() map[string]*element.Element {
	return bldr.pool
}
