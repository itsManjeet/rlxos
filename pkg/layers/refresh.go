package layers

import (
	"log"
	"path"
	"syscall"
)

func (m *Manager) Refresh() error {
	var flag uintptr = 0
	isMounted, err := checkIsMounted()
	if err != nil {
		return err
	}
	if isMounted {
		flag = syscall.MS_REMOUNT
	}
	lower := m.RootDir
	for _, l := range m.Layers {
		log.Printf("enabling layer %s\n", l.Id)
		lower += ":" + path.Join(m.RootDir, l.Path)
	}
	log.Println("LOWERDIR", lower)
	if err := syscall.Mount("overlay", m.RootDir, "overlay", flag, "lowerdir="+lower); err != nil {
		return err
	}
	return nil
}
