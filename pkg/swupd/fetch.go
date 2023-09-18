package swupd

import (
	"encoding/json"
	"fmt"
	"net/http"
	"rlxos/pkg/updates/config"
)

func (s *Swupd) Fetch() (*config.UpdateInfo, error) {
	url := fmt.Sprintf("%s/%s", s.config.Server, s.config.Channel)
	resp, err := http.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch metadata %s, %v", url, err)
	}
	defer resp.Body.Close()

	updateInfo := &config.UpdateInfo{}
	if err := json.NewDecoder(resp.Body).Decode(updateInfo); err != nil {
		return nil, fmt.Errorf("failed to fetch metadata %s, %v", url, err)
	}
	return updateInfo, nil
}
