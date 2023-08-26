package layers

import (
	"fmt"
	"os"
	"path"
)

func (m *Manager) Create(id string) error {
	layerPath := path.Join(m.SearchPath[0], id)
	if err := os.MkdirAll(layerPath, 0755); err != nil {
		return fmt.Errorf("failed to create layer at %s, %v", layerPath, err)
	}
	return m.Refresh()
}
