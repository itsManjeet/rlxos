package layers

import (
	"fmt"
	"log"
	"path"
	"rlxos/pkg/osinfo"
)

func (m *Manager) Refresh(deactivate bool) error {
	layers, err := m.LoadLayers()
	if err != nil {
		return err
	}

	if deactivate {
		layers = []Layer{}
	}

	mounts, err := osinfo.GetMounts(path.Join(m.RootDir, "proc", "mounts"))
	if err != nil {
		return fmt.Errorf("failed to read mount information %v", err)
	}

	isAlreadyMounted := false
	for _, mountInfo := range mounts {
		if mountInfo.Target == "/usr" && mountInfo.Source == "overlay" {
			isAlreadyMounted = true
			break
		}
	}

	log.Printf("found %d layers\n", len(layers))

	return m.Mount(path.Join(m.RootDir, "usr"), layers, isAlreadyMounted)
}
