package installer

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path"
	"rlxos/pkg/element"
	"rlxos/pkg/osinfo"
)

func (i *Installer) getMetadata() ([]element.Metadata, error) {
	o, err := osinfo.Open(path.Join("/", "etc", "os-release"))
	if err != nil {
		return nil, err
	}
	resp, err := http.Get(i.ServerUrl + "/" + o["VERSION"])
	if err != nil {
		return nil, fmt.Errorf("failed to get meta info %v", err)
	}
	defer resp.Body.Close()

	metadata := []element.Metadata{}
	if err := json.NewDecoder(resp.Body).Decode(&metadata); err != nil {
		return nil, fmt.Errorf("invalid format of meta info %v", err)
	}

	return metadata, nil
}
