package installer

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/exec"
	"path"
	"rlxos/pkg/element"
	"rlxos/pkg/osinfo"
	"rlxos/pkg/utils"
	"strings"

	"gopkg.in/yaml.v2"
)

func (i *Installer) Install(layerid string) error {
	o, err := osinfo.Open(path.Join("/", "etc", "os-release"))
	if err != nil {
		return err
	}
	resp, err := http.Get(i.ServerUrl + "/" + o["VERSION"])
	if err != nil {
		return fmt.Errorf("failed to get meta info %v", err)
	}
	defer resp.Body.Close()

	metadata := []element.Metadata{}
	if err := json.NewDecoder(resp.Body).Decode(&metadata); err != nil {
		return fmt.Errorf("invalid format of meta info %v", err)
	}

	var requiredElement *element.Metadata
	for _, elementInfo := range metadata {
		if elementInfo.Type == element.ElementTypeLayer {
			if layerid == elementInfo.Id {
				requiredElement = &elementInfo
				break
			}
		}
	}

	if requiredElement == nil {
		return fmt.Errorf("no layer found with id %s", layerid)
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
