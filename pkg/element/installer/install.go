package installer

import (
	"fmt"
	"io/fs"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"rlxos/pkg/color"
	"rlxos/pkg/element"
	"rlxos/pkg/utils"
	"strings"

	"gopkg.in/yaml.v2"
)

func (i *Installer) Install(componentId string) error {
	metadata, err := i.getMetadata()
	if err != nil {
		return nil
	}
	var requiredElement *element.Metadata
	for _, elementInfo := range metadata {
		if elementInfo.Type == element.ElementTypeLayer || elementInfo.Type == element.ElementTypeComponent {
			if componentId == elementInfo.Id {
				requiredElement = &elementInfo
				break
			}
		}
	}

	if requiredElement == nil {
		return fmt.Errorf("no layer found with id %s", componentId)
	}

	log.Printf("Dowloading %s [%s]\n", requiredElement.Id, requiredElement.Cache)
	cachefile := path.Join(i.componentsCachePath, requiredElement.Cache)
	if err := utils.DownloadFile(cachefile, i.ServerUrl+"/cache/"+requiredElement.Cache); err != nil {
		return fmt.Errorf("failed to download %s, %v", cachefile, err)
	}
	log.Printf("Installing %s\n", requiredElement.Id)
	data, err := exec.Command("tar", "-xvaf", cachefile, "-C", i.LayerPath).CombinedOutput()
	if err != nil {
		return fmt.Errorf("failed to extract %s, %s %v", requiredElement.Id, string(data), err)
	}

	elementId := strings.ReplaceAll(requiredElement.Id, "/", "_")

	factoryConfig := path.Join(i.LayerPath, "share", "factory", "etc")
	if _, err := os.Stat(factoryConfig); err == nil {
		filepath.Walk(factoryConfig, func(p string, info fs.FileInfo, err error) error {
			if err != nil {
				return err
			}
			if info.IsDir() {
				return nil
			}

			configPath := strings.TrimPrefix(p, factoryConfig)
			if _, err := os.Stat(path.Join(i.RootPath, "etc", configPath)); os.IsNotExist(err) {
				if err := utils.CopyFile(p, path.Join(i.RootPath, "etc", configPath)); err != nil {
					color.Error("failed to install configuration %s\n", p)
				}
			}
			return nil
		})

	}

	log.Printf("Registering component information %s\n", requiredElement.Id)
	if err := os.WriteFile(path.Join(i.componentsDataPath, elementId+".files"), data, 0644); err != nil {
		return fmt.Errorf("failed to write installed files info %v", err)
	}

	elementData, err := yaml.Marshal(*requiredElement)
	if err != nil {
		return fmt.Errorf("failed to serialize element data, %v", err)
	}

	if err := os.WriteFile(path.Join(i.componentsDataPath, elementId+".info"), elementData, 0644); err != nil {
		return fmt.Errorf("failed to write installed files info %v", err)
	}

	return nil
}
