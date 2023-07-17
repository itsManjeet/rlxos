package backend

import (
	"encoding/json"
	"net/http"
	"rlxos/src/swupd/config"
)

type Backend struct {
	config *config.Config
}

func New(c *config.Config) *Backend {
	return &Backend{config: c}
}

func (b *Backend) request(url string, target interface{}) error {
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()
	return json.NewDecoder(resp.Body).Decode(target)
}
