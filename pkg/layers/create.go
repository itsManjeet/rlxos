package layers

import (
	"fmt"
	"log"
	"os"
	"path"
	"rlxos/pkg/element/installer"
)

func (m *Manager) Add(id string, layerid string) error {
	layerPath := path.Join(m.RootDir, m.SearchPath[0], id)
	if err := os.MkdirAll(layerPath, 0755); err != nil {
		return fmt.Errorf("failed to create layer at %s, %v", layerPath, err)
	}
	if layerid != "" {
		inst := &installer.Installer{
			LayerPath: layerPath,
			RootPath:  m.RootDir,
			ServerUrl: m.ServerUrl,
		}

		log.Printf("Initializing installer for %s\n", layerid)
		if err := inst.Init(layerid); err != nil {
			return fmt.Errorf("failed to initialize installer %v", err)
		}

		log.Printf("Installing %s\n", layerid)
		if err := inst.Install(layerid); err != nil {
			return fmt.Errorf("installation failed %v", err)
		}
	} else {
		log.Println("layers id is null")
	}
	return m.Refresh(false)
}
