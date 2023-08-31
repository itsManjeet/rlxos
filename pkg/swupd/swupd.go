package swupd

import (
	"encoding/json"
	"fmt"
	"net/http"
	"path"
	"rlxos/pkg/osinfo"
)

type Swupd struct {
	config *Config
	OsInfo osinfo.OsInfo
}

func New(c *Config) (*Swupd, error) {
	os_release, err := osinfo.Open(path.Join("/", "usr", "lib", "os-release"))
	if err != nil {
		return nil, fmt.Errorf("failed to read os-release, %v", err)
	}
	return &Swupd{config: c, OsInfo: os_release}, nil
}

func (s *Swupd) request(url string, target interface{}) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return json.NewDecoder(resp.Body).Decode(target)
}
