package layers

import (
	"fmt"
	"os"
	"path"
)

func (m *Manager) Remove(id string) error {
	layerPath := path.Join(m.SearchPath[0], id)
	if err := os.RemoveAll(layerPath); err != nil {
		return fmt.Errorf("failed to remove layer at %s, %v", layerPath, err)
	}
	return m.Refresh(false)
}
