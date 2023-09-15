package installer

import (
	"fmt"
	"os"
	"path"
)

type Installer struct {
	LayerPath string
	RootPath  string
	ServerUrl string

	layerid string

	componentsCachePath string
	componentsDataPath  string
}

func (i *Installer) Init(layerid string) error {
	i.layerid = layerid
	i.componentsCachePath = path.Join(i.RootPath, "var", "cache", "components")
	i.componentsDataPath = path.Join(i.LayerPath, "share", "layers", layerid, "components")
	for _, dir := range []string{i.LayerPath, i.componentsCachePath, i.componentsDataPath} {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return fmt.Errorf("failed to create required path %s, %v", dir, err)
		}
	}
	return nil
}
