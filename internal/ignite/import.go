package ignite

import (
	"fmt"
	"os"

	"gopkg.in/yaml.v2"
)

func (bldr *Ignite) Import(configfile string) error {
	data, err := os.ReadFile(configfile)
	if err != nil {
		return fmt.Errorf("failed to import %s: %v", configfile, err)
	}

	config := &Ignite{
		Environ:    []string{},
		BuildTools: []BuildTool{},
		Imports:    []string{},
		Variables:  map[string]string{},
	}
	if err := yaml.Unmarshal(data, config); err != nil {
		return fmt.Errorf("failed to import %s: %v", configfile, err)
	}

	for _, importfile := range config.Imports {
		if err := config.Import(importfile); err != nil {
			return fmt.Errorf("failed to import %s: %v", importfile, err)
		}
	}

	updateIfMissing := func(orig, updated string) string {
		if len(updated) == 0 {
			return orig
		}
		return updated
	}

	bldr.Container = updateIfMissing(bldr.Container, config.Container)
	bldr.CachePath = updateIfMissing(bldr.CachePath, config.CachePath)
	bldr.ArtifactServer = updateIfMissing(bldr.ArtifactServer, config.ArtifactServer)
	for key, value := range config.Variables {
		if _, ok := bldr.Variables[key]; !ok {
			bldr.Variables[key] = value
		}
	}

	bldr.Shell.Environ = append(config.Shell.Environ, bldr.Shell.Environ...)
	bldr.Shell.Bind = append(config.Shell.Bind, bldr.Shell.Bind...)

	bldr.Environ = append(config.Environ, bldr.Environ...)
	bldr.BuildTools = append(config.BuildTools, bldr.BuildTools...)

	return nil
}
