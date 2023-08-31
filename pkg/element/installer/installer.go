package installer

import (
	"fmt"
	"os"
	"path"
)

type Installer struct {
	LayerPath string `yaml:"layer-path"`
	RootPath  string `yaml:"root-path"`
	ServerUrl string `yaml:"server-url"`

	componentsCachePath string
	componentsDataPath  string
}

func (i *Installer) Init() error {
	i.componentsCachePath = path.Join(i.RootPath, "var", "cache", "components")
	i.componentsDataPath = path.Join(i.RootPath, "var", "lib", "components")
	for _, dir := range []string{i.LayerPath, i.componentsCachePath, i.componentsDataPath} {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create required path %s, %v", dir, err)
		}
	}
	return nil
}
