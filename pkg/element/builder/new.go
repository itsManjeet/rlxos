package builder

import (
	"fmt"
	"io/fs"
	"os"
	"path"
	"path/filepath"
	"rlxos/pkg/color"
	"rlxos/pkg/element"
	"strings"

	"dario.cat/mergo"
	"gopkg.in/yaml.v2"
)

func New(projectPath string, cachePath string) (*Builder, error) {
	color.Process("Loading configuration")
	data, err := os.ReadFile(path.Join(projectPath, "config.yml"))
	if err != nil {
		return nil, err
	}

	var b Builder
	if err := yaml.Unmarshal(data, &b); err != nil {
		return nil, err
	}

	for _, mergefile := range b.Merge {
		data, err := os.ReadFile(path.Join(projectPath, mergefile))
		if err != nil {
			return nil, err
		}
		var mergingConfig Builder
		if err := yaml.Unmarshal(data, &mergingConfig); err != nil {
			return nil, err
		}
		if err := mergo.Merge(&b, mergingConfig); err != nil {
			return nil, err
		}
	}

	b.pool = map[string]*element.Element{}

	if b.Environ == nil {
		b.Environ = []string{}
	}
	if b.Variables == nil {
		b.Variables = map[string]string{}
	}
	b.projectPath = projectPath
	b.cachePath = cachePath

	color.Process("Loading elements")
	if err := filepath.WalkDir(path.Join(projectPath, "elements"), func(p string, d fs.DirEntry, err error) error {
		elementType := strings.Split(strings.Trim(strings.TrimPrefix(p, path.Join(projectPath, "elements")), "/"), "/")[0]
		if elementType == "experimental" {
			return nil
		}
		if path.Ext(p) == ".yml" {
			e, err := element.Open(p, b.Environ, b.Variables)
			if err != nil {
				return fmt.Errorf("failed to load element %s, %v", p, err)
			}
			p = strings.TrimPrefix(p, path.Join(projectPath, "elements")+"/")
			b.pool[p] = e
		}
		return nil
	}); err != nil {
		return nil, err
	}

	return &b, nil
}

func (b *Builder) Pool() map[string]*element.Element {
	return b.pool
}
