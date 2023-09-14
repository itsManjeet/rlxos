package layers

import (
	"io/ioutil"
	"log"
	"os"
	"path"
)

func (m *Manager) Sync() {
	m.Layers = []Layer{}
	for _, i := range m.SearchPath {
		dir, err := ioutil.ReadDir(path.Join(m.RootDir, i))
		if err != nil {
			log.Printf("failed to read %s, %v", i, err)
			continue
		}

		for _, l := range dir {
			isDisabled := false
			if _, err := os.Stat(path.Join(i, l.Name(), "disabled")); err == nil {
				isDisabled = true
			}
			if l.IsDir() {
				m.Layers = append(m.Layers, Layer{
					Id:       l.Name(),
					Path:     path.Join(i, l.Name()),
					Active:   false,
					Disabled: isDisabled,
				})
			}
		}
	}
}