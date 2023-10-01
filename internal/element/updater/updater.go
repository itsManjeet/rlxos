package updater

import (
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"rlxos/internal/element"

	"gopkg.in/yaml.v2"
)

type Updater struct {
	Url   string            `yaml:"url"`
	Skip  []string          `yaml:"skip"`
	Alias map[string]string `yaml:"alias"`
}

type ReleaseMonitoringResponse struct {
	Items []struct {
		Distribution  string `json:"distribution"`
		Name          string `json:"name"`
		Project       string `json:"project"`
		StableVersion string `json:"stable_version"`
		Version       string `json:"version"`
	} `json:"items"`
}

func New(config string) (*Updater, error) {
	data, err := os.ReadFile(config)
	if err != nil {
		return nil, fmt.Errorf("failed to read update configuration file, %v", err)
	}

	var u Updater
	if err := yaml.Unmarshal(data, &u); err != nil {
		return nil, err
	}
	return &u, nil
}

func (u *Updater) GetUpdate(el *element.Element) (string, error) {
	for _, i := range u.Skip {
		if i == el.Id {
			return "", nil
		}
	}
	id, ok := u.Alias[el.Id]
	if !ok {
		id = el.Id
	}
	requestURL := u.Url + "/?name=" + id
	resp, err := http.Get(requestURL)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var r ReleaseMonitoringResponse
	if err := json.NewDecoder(resp.Body).Decode(&r); err != nil {
		return "", err
	}

	if len(r.Items) == 0 {
		return "", fmt.Errorf("no update items found")
	}

	return r.Items[0].StableVersion, nil
}
