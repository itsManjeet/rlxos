package installer

import (
	"encoding/json"
	"fmt"
	"net/http"
	"rlxos/internal/element"
)

func (i *Installer) getMetadata() ([]element.Metadata, error) {
	resp, err := http.Get(i.ServerUrl + "/" + "metadata.json")
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
