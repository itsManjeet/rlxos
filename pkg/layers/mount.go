package layers

import (
	"log"
	"path"
	"syscall"
)

func (m *Manager) Mount(target string, layers []Layer, remount bool) error {
	var flags uintptr = syscall.MS_RDONLY
	if remount {
		flags |= syscall.MS_REMOUNT
	}

	options := "lowerdir="
	for _, layer := range layers {
		if layer.Disabled {
			log.Println("DISABLED", layer.Id)
			continue
		}
		options += path.Join(m.RootDir, layer.Path) + ":"
	}
	options += target

	return syscall.Mount("overlay", target, "overlay", flags, options)
}
