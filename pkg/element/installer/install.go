package installer

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/element"
	"rlxos/pkg/utils"
	"strings"
)

func (i *Installer) Install(c ...string) error {
	metadataJson := path.Join(i.componentsCachePath, "metadata.json")
	metadata := []element.Metadata{}
	data, err := os.ReadFile(metadataJson)
	if err != nil {
		return fmt.Errorf("failed to read metadata %s, %v", metadataJson, err)
	}
	if err := json.Unmarshal(data, &metadata); err != nil {
		return fmt.Errorf("failed to read metadata %s, %v", metadataJson, err)
	}

	componentInfo := []element.Metadata{}
	for _, elementId := range c {
		found := false
		for _, elementInfo := range metadata {
			if elementInfo.Id == elementId || elementInfo.Id == elementId+".yml" {
				componentInfo = append(componentInfo, elementInfo)
				found = true
				break
			}
		}
		if !found {
			return fmt.Errorf("missing component with id %s", elementId)
		}
	}

	for _, elementInfo := range componentInfo {
		log.Printf("Dowloading %s [%s]\n", elementInfo.Id, elementInfo.Cache)
		cachefile := path.Join(i.componentsCachePath, elementInfo.Cache)
		if err := utils.DownloadFile(cachefile, i.ServerUrl+"/cache/"+cachefile); err != nil {
			return fmt.Errorf("failed to download %s, %v", cachefile, err)
		}
		log.Printf("Installing %s\n", elementInfo.Id)
		data, err := exec.Command("tar", "-xvaf", cachefile, "-C", i.LayerPath).CombinedOutput()
		if err != nil {
			return fmt.Errorf("failed to extract %s, %s %v", elementInfo.Id, string(data), err)
		}

		elementId := strings.ReplaceAll(elementInfo.Id, "/", "_")

		log.Printf("Registering component information %s\n", elementInfo.Id)
		if err := os.WriteFile(path.Join(i.componentsDataPath, elementId+".files"), data, 0644); err != nil {
			return fmt.Errorf("failed to write installed files info %v", err)
		}

		if err := os.WriteFile(path.Join(i.componentsDataPath, elementId+".ref"), []byte(elementInfo.Cache), 0644); err != nil {
			return fmt.Errorf("failed to write installed files info %v", err)
		}
	}

	return nil
}
