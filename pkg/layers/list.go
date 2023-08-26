package layers

import (
	"fmt"
	"path"
)

func (m *Manager) List() ([]Layer, error) {
	mountedLayers, _, err := parseMountData()
	if err != nil {
		return nil, err
	}
	m.Sync()
	resLayers := m.Layers
	for i, l := range resLayers {
		if contains(mountedLayers, path.Join(m.RootDir, l.Path)) {
			resLayers[i].Active = true
		}
	}
	if err != nil {
		return nil, fmt.Errorf("failed to list layers, %v", err)
	}
	return resLayers, nil
}
